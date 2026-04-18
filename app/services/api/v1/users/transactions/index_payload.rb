# frozen_string_literal: true

module Api
  module V1
    module Users
      module Transactions
        class IndexPayload
          def self.call(transactions)
            { transactions: transactions.map { |t| row(t) } }
          end

          def self.row(transaction)
            {
              id: transaction.id,
              status: transaction.status,
              name: transaction.name,
              amount: transaction.amount.to_f,
              currency: transaction.currency,
              transaction_date: transaction.transaction_date,
              total_vat: transaction.total_vat&.to_f,
              store_name: transaction.store_name,
              image_urls: transaction.image_urls,
              created_at: transaction.created_at,
              updated_at: transaction.updated_at
            }
          end
        end
      end
    end
  end
end
