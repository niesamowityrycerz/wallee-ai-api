# frozen_string_literal: true

module Api
  module V1
    module Users
      module Transactions
        module Tags
          class UpdateService < BaseService
            def initialize(transaction:, params:)
              @transaction = transaction
              @params = params
            end

            def call
              validate_status!
              validated = validate(contract, @params)
              apply!(validated)
              { success: true, tags: tag_payload }
            end

            private

            attr_reader :transaction, :params

            def contract
              @contract ||= ::Api::V1::Users::Transactions::Tags::UpdateContract.new
            end

            def validate_status!
              return if transaction.ready?

              raise ValidationError.new({ status: [ "transaction must have status 'ready' to be edited" ] })
            end

            def apply!(validated)
              ::Api::V1::Users::Transactions::Tag::Edit.new(
                transaction: transaction,
                add_tag_ids: validated[:add_tag_ids],
                remove_tag_ids: validated[:remove_tag_ids]
              ).call
            end

            def tag_payload
              transaction.reload
              ::Api::V1::Users::Transactions::TagAssignmentList.call(transaction)
            end
          end
        end
      end
    end
  end
end
