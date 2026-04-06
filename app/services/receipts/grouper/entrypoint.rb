# frozen_string_literal: true

module Receipts
  module Grouper
    class Entrypoint
      include SolidQueueLoggable

      attr_reader :user, :image_urls

      def initialize(user_id:, image_urls:)
        @user = User.find(user_id)
        @image_urls = image_urls
      end

      def call
        response = agent.ask(user_prompt, with: image_urls)
        # TODO: validate the response
        create_shell_transactions!(response.content["groups"])
        { success: true }
      rescue StandardError => e
        # mozliwe jest ze open ai zwroci blad ze byl timeout na pobraniu obrazkow
        # trzeba wtedy by zrobic jakis retry logic 
        logger.error("Receipt grouping failed for user #{user.id}: #{e.message}")
        { success: false, error: e.message }
      end

      private

      def agent
        @agent ||= ::ReceiptGroupingAgent.new
      end

      def user_prompt
        <<~PROMPT
          Group the provided receipt images by receipt.

          IMPORTANT: The image_urls in your response must be copied exactly as provided — character for character.
          Do not modify, shorten, rewrite, or generate any URLs. Only use the following URLs:
          #{image_urls.map { |url| "- #{url}" }.join("\n")}
        PROMPT
      end

      def create_shell_transactions!(groups)
        groups.each { |group| create_shell_transaction_and_enqueue!(group["image_urls"]) }
      end

      def create_shell_transaction_and_enqueue!(group_image_urls)
        logger.info "Creating shell transaction and enqueuing analysis for group image urls: #{group_image_urls}"
        transaction = nil

        ActiveRecord::Base.transaction do
          transaction = user.transactions.create!(status: :in_progress)
          group_image_urls.each { |url| transaction.images.create!(image_url: url) }
        end

        logger.info "Creating shell transaction and enqueuing analysis for transaction #{transaction.id}"

        Transaction::Analysis.perform_later(transaction.id)
      end
    end
  end
end
