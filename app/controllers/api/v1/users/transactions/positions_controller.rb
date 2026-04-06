# frozen_string_literal: true

module Api
  module V1
    module Users
      module Transactions
        class PositionsController < ApplicationController
          before_action :authorize_user!

          def update
            transaction = current_user.transactions.find_by(id: params[:transaction_id])
            return render json: { error: "Transaction not found" }, status: :not_found unless transaction

            position = transaction.positions.find_by(id: params[:id])
            return render json: { error: "Position not found" }, status: :not_found unless position

            result = Api::V1::Users::Transactions::Positions::UpdateService.new(
              transaction: transaction,
              position: position,
              params: update_params
            ).call

            render json: result[:data], status: :ok
          rescue BaseService::ValidationError => e
            render json: { errors: e.errors }, status: :unprocessable_entity
          end

          def destroy
            transaction = current_user.transactions.find_by(id: params[:transaction_id])
            return render json: { error: "Transaction not found" }, status: :not_found unless transaction

            position = transaction.positions.find_by(id: params[:id])
            return render json: { error: "Position not found" }, status: :not_found unless position

            result = Api::V1::Users::Transactions::Positions::DestroyService.new(
              transaction: transaction,
              position: position
            ).call

            render json: result[:data], status: :ok
          rescue BaseService::ValidationError => e
            render json: { errors: e.errors }, status: :unprocessable_entity
          end

          private

          def update_params
            params.permit(:name, :quantity, :unit_price, :total_discount, :category)
                  .to_h.deep_symbolize_keys
          end

          def authorize_user!
            return if params[:user_id].to_s == current_user.id.to_s

            render json: { error: "Forbidden" }, status: :forbidden
          end
        end
      end
    end
  end
end
