# frozen_string_literal: true

module Api
  module V1
    module Users
      module Transactions
        class UpdateService < BaseService
          UPDATABLE_FIELDS = %i[name amount currency transaction_date store_name store_address total_discount].freeze

          def initialize(transaction:, params:)
            @transaction = transaction
            @params = params
          end

          def call
            validate_status!
            validated = validate(contract, @params)
            transaction.update!(validated.slice(*UPDATABLE_FIELDS))

            { success: true, data: serialize }
          end

          private

          attr_reader :transaction, :params

          def contract
            @contract ||= ::Api::V1::Users::Transactions::UpdateContract.new
          end

          def validate_status!
            return if transaction.ready?

            raise ValidationError.new({ status: ["transaction must have status 'ready' to be edited"] })
          end

          def serialize
            {
              id: transaction.id,
              name: transaction.name,
              amount: transaction.amount&.to_f,
              currency: transaction.currency,
              transaction_date: transaction.transaction_date,
              store_name: transaction.store_name,
              store_address: transaction.store_address,
              total_discount: transaction.total_discount,
              status: transaction.status,
              created_at: transaction.created_at,
              updated_at: transaction.updated_at
            }
          end
        end
      end
    end
  end
end
