# frozen_string_literal: true

module Api
  module V1
    module Users
      module Transactions
        class TagsController < ApplicationController
          before_action :authorize_user!

          def create
            transaction = current_user.transactions.find_by(id: params[:transaction_id])
            return render json: { error: "Transaction not found" }, status: :not_found unless transaction

            Api::V1::Users::Transactions::Tags::CreateService.new(
              transaction: transaction,
              params: create_params
            ).call

            head :created
          rescue BaseService::ValidationError => e
            render json: { errors: e.errors }, status: :unprocessable_entity
          end

          def update
            transaction = current_user.transactions.find_by(id: params[:transaction_id])
            return render json: { error: "Transaction not found" }, status: :not_found unless transaction

            result = Api::V1::Users::Transactions::Tags::UpdateService.new(
              transaction: transaction,
              params: update_params
            ).call

            render json: { tags: result[:tags] }, status: :ok
          rescue BaseService::ValidationError => e
            render json: { errors: e.errors }, status: :unprocessable_entity
          end

          private

          def create_params
            params.permit(:name).to_h.deep_symbolize_keys
          end

          def update_params
            params.permit(add_tag_ids: [], remove_tag_ids: []).to_h.deep_symbolize_keys
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
