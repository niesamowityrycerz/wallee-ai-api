# frozen_string_literal: true

module Receipts
  module Analyzer
    class Entrypoint
      include SolidQueueLoggable

      attr_reader :transaction

      def initialize(transaction:)
        @transaction = transaction
      end

      def call
        response = agent.ask(user_prompt, with: transaction.image_urls)

        logger.info "Receipt analysis response: #{response.content}"

        Receipts::Analyzer::StoreAnalysis.new(
          transaction: transaction,
          analysis: response.content
        ).call

        logger.info "Receipt analysis completed for transaction #{transaction.id}"

        { success: true }
      rescue StandardError => e
        logger.error(
          "Receipt analysis failed for transaction #{transaction.id}: #{e.message}"
        )
        { success: false, error: e.message }
      end

      private

      def agent
        @agent ||= ::ReceiptAnalyzerAgent.new
      end

      def user_prompt
        "Analyze the receipt from the provided images and extract all data."
      end
    end
  end
end
