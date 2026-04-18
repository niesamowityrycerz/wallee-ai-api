# frozen_string_literal: true

module Receipts
  module Tagger
    class Entrypoint
      include SolidQueueLoggable

      MAX_CATALOG_TAGS = 500

      def initialize(transaction:)
        @transaction = transaction
      end

      def call
        account = transaction.user.account
        if account.blank?
          logger.warn("Transaction tagging skipped: user #{transaction.user_id} has no account")
          return { success: false, skipped: true }
        end

        run_agent!(account)
        { success: true }
      rescue StandardError => e
        logger.warn(
          "Transaction tagging failed for transaction #{transaction.id}: #{e.class}: #{e.message}"
        )
        { success: false }
      end

      private

      attr_reader :transaction

      def run_agent!(account)
        message = build_message(account)
        response = agent.ask(message)
        content = response.content
        if content.blank?
          logger.warn("Transaction tagging empty response for transaction #{transaction.id}")
          return
        end

        ApplyLlmResult.new(transaction: transaction, result: content).call
      end

      def build_message(account)
        catalog = tag_catalog(account)
        payload = BuildPayload.new(transaction).call
        <<~MSG
          ## Tag catalog (JSON)
          #{JSON.generate(catalog)}

          ## Transaction (JSON)
          #{JSON.generate(payload)}
        MSG
      end

      def tag_catalog(account)
        account.tags.order(:id).limit(MAX_CATALOG_TAGS).pluck(:id, :name).map do |id, name|
          { id: id, name: name }
        end
      end

      def agent
        @agent ||= ::TransactionTaggingAgent.new
      end
    end
  end
end
