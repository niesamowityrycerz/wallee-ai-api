# frozen_string_literal: true

module Api
  module V1
    module Users
      module Transactions
        module Positions
          class DestroyService < BaseService
            def initialize(transaction:, position:)
              @transaction = transaction
              @position = position
            end

            def call
              validate_status!
              ActiveRecord::Base.transaction do
                position.destroy!
                sync_transaction_totals!
              end

              { success: true, data: serialize }
            end

            private

            attr_reader :transaction, :position

            def validate_status!
              return if transaction.ready?

              raise ValidationError.new({ status: [ "transaction must have status 'ready' to be edited" ] })
            end

            def sync_transaction_totals!
              transaction.reload
              transaction.update!(
                amount: transaction.positions.sum(:total_price),
                total_discount: transaction.positions.sum(:total_discount)
              )
            end

            def serialize
              txn = transaction.reload
              {
                transaction: {
                  total_price: txn.amount.to_f,
                  total_discount: txn.total_discount&.to_f
                }
              }
            end
          end
        end
      end
    end
  end
end
