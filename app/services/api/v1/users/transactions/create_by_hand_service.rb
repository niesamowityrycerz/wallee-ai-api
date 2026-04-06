# frozen_string_literal: true

module Api
  module V1
    module Users
      module Transactions
        class CreateByHandService < BaseService
          def initialize(user:, params:)
            @user = user
            @params = params
          end

          def call
            validated = validate(contract, @params)
            create_transaction!(validated)
            { success: true, transaction: @transaction }
          end

          private

          attr_reader :user, :params

          def contract
            @contract ||= ::Api::V1::Users::Transactions::CreateByHandContract.new
          end

          def create_transaction!(validated_params)
            ActiveRecord::Base.transaction do
              @transaction = user.transactions.create!(
                name: validated_params[:title],
                store_name: validated_params[:store_name],
                amount: validated_params[:total_price],
                currency: validated_params[:currency],
                transaction_date: validated_params[:transaction_date],
                status: :ready
              )
              create_positions!(validated_params[:positions])
              sync_transaction_total_discount! if validated_params[:positions].any?
            end
          end

          def create_positions!(positions)
            return if positions.empty?

            positions.each do |position|
              @transaction.positions.create!(position_attributes(position))
            end
          end

          def position_attributes(position)
            discount = position[:total_discount].to_d
            {
              name: position[:name],
              quantity: position[:quantity],
              unit_price: position[:price],
              category: position[:category],
              total_discount: discount,
              total_price: ::Transaction::Position.total_price_for(
                quantity: position[:quantity],
                unit_price: position[:price],
                total_discount: discount
              )
            }
          end

          def sync_transaction_total_discount!
            @transaction.update!(total_discount: @transaction.positions.sum(:total_discount))
          end
        end
      end
    end
  end
end
