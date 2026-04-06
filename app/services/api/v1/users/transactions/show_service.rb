# frozen_string_literal: true

module Api
  module V1
    module Users
      module Transactions
        class ShowService
          attr_reader :user, :id, :transaction

          def initialize(user:, id:)
            @user = user
            @id = id
            @transaction = nil
          end

          def call
            @transaction = user.transactions.includes(:images, :positions).find_by(id: id)
            return { success: false, error: "Transaction not found" } unless transaction

            { success: true, data: serialize }
          end

          private

          def serialize
            {
              id: transaction.id,
              status: transaction.status,
              name: transaction.name,
              amount: transaction.amount.to_f,
              currency: transaction.currency,
              transaction_date: transaction.transaction_date,
              store_name: transaction.store_name,
              store_address: transaction.store_address,
              image_urls: transaction.image_urls,
              total_discount: transaction.total_discount,
              products: transaction.positions.map { |p| serialize_position(p) },
              created_at: transaction.created_at,
              updated_at: transaction.updated_at
            }
          end

          def serialize_position(position)
            {
              id: position.id,
              name: position.name,
              quantity: position.quantity,
              unit_price: position.unit_price.to_f,
              total_price: position.total_price.to_f,
              category: position.category,
              total_discount: position.total_discount
            }
          end
        end
      end
    end
  end
end
