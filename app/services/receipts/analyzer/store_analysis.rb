# frozen_string_literal: true

module Receipts
  module Analyzer
    class StoreAnalysis
      attr_reader :transaction, :analysis

      def initialize(transaction:, analysis:)
        @transaction = transaction
        @analysis = analysis
      end

      def call
        ActiveRecord::Base.transaction do
          transaction.positions.destroy_all
          transaction.update!(transaction_attributes)
          create_positions!
        end
      end

      private

      def transaction_attributes
        {
          name: build_name,
          amount: analysis["total_amount"],
          currency: analysis["currency"].upcase,
          transaction_date: analysis["transaction_date"],
          store_name: analysis["store_name"],
          store_address: analysis["store_address"],
          total_discount: analysis["total_discount"] || 0
        }
      end

      def build_name
        [analysis["store_name"], analysis["transaction_date"]]
          .compact
          .join(" - ")
      end

      def create_positions!
        return if analysis["positions"].blank?

        analysis["positions"].each do |pos|
          discount = pos["total_discount"] || 0
          transaction.positions.create!(
            name: pos["name"],
            quantity: pos["quantity"],
            unit_price: pos["unit_price"],
            category: pos["category"],
            total_discount: discount,
            total_price: Transaction::Position.total_price_for(
              quantity: pos["quantity"],
              unit_price: pos["unit_price"],
              total_discount: discount
            )
          )
        end
      end
    end
  end
end
