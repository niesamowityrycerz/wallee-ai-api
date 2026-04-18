# frozen_string_literal: true

module Receipts
  module Tagger
    class BuildPayload
      MAX_LINE_ITEMS = 50

      def initialize(transaction)
        @transaction = transaction
      end

      def call
        {
          store_name: transaction.store_name,
          transaction_date: format_date(transaction.transaction_date),
          line_items: line_items
        }
      end

      private

      attr_reader :transaction

      def format_date(date)
        date&.strftime("%Y-%m-%d")
      end

      def line_items
        transaction.positions.order(:id).limit(MAX_LINE_ITEMS).map do |pos|
          { name: pos.name, category: pos.category }
        end
      end
    end
  end
end
