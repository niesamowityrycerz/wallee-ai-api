# frozen_string_literal: true

module Api
  module V1
    module Users
      module Transactions
        module Positions
          class UpdateService < BaseService
            UPDATABLE_FIELDS = %i[name quantity unit_price total_discount category].freeze

            def initialize(transaction:, position:, params:)
              @transaction = transaction
              @position = position
              @params = params
            end

            def call
              validate_status!
              validated = validate(contract, @params)
              ActiveRecord::Base.transaction do
                position.update!(attributes_with_total_price(validated))
                sync_transaction_totals!(validated)
              end

              { success: true, data: serialize }
            end

            private

            attr_reader :transaction, :position, :params

            def contract
              @contract ||= ::Api::V1::Users::Transactions::Positions::UpdateContract.new
            end

            def validate_status!
              return if transaction.ready?

              raise ValidationError.new({ status: [ "transaction must have status 'ready' to be edited" ] })
            end

            def attributes_with_total_price(validated)
              attrs = validated.slice(*UPDATABLE_FIELDS)
              attrs[:total_price] = merged_total_price(attrs)
              attrs
            end

            def merged_total_price(attrs)
              quantity = attrs.fetch(:quantity, position.quantity)
              unit_price = attrs.fetch(:unit_price, position.unit_price)
              discount = attrs.key?(:total_discount) ? attrs[:total_discount] : position.total_discount
              ::Transaction::Position.total_price_for(
                quantity: quantity,
                unit_price: unit_price,
                total_discount: discount
              )
            end

            def sync_transaction_totals!(validated)
              attrs = {}
              if position_total_price_inputs_changed?(validated)
                attrs[:amount] = sum_of_position_total_prices
              end
              if validated.key?(:total_discount)
                attrs[:total_discount] = sum_of_position_total_discounts
              end
              transaction.update!(attrs) if attrs.any?
            end

            def position_total_price_inputs_changed?(validated)
              validated.key?(:quantity) || validated.key?(:unit_price) || validated.key?(:total_discount)
            end

            def sum_of_position_total_prices
              transaction.positions.sum(:total_price)
            end

            def sum_of_position_total_discounts
              transaction.positions.sum(:total_discount)
            end

            def serialize
              txn = transaction.reload
              {
                id: position.id,
                name: position.name,
                quantity: position.quantity.to_f,
                unit_price: position.unit_price.to_f,
                total_price: position.total_price.to_f,
                total_discount: position.total_discount&.to_f,
                category: position.category,
                created_at: position.created_at,
                updated_at: position.updated_at,
                transaction: transaction_payload(txn)
              }
            end

            def transaction_payload(txn)
              {
                total_price: txn.amount.to_f,
                total_discount: txn.total_discount&.to_f
              }
            end
          end
        end
      end
    end
  end
end
