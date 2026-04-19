# frozen_string_literal: true

module Api
  module V1
    module Users
      class TagsController < ApplicationController
        before_action :authorize_user!

        def index
          result = Api::V1::Users::Tags::IndexService.new(
            user: current_user,
            params: index_params
          ).call
          render json: result, status: :ok
        rescue BaseService::ValidationError => e
          render json: { errors: e.errors }, status: :unprocessable_entity
        end

        def create
          result = Api::V1::Users::Tags::CreateService.new(
            user: current_user,
            params: create_params
          ).call
          render json: result[:data], status: :created
        rescue BaseService::ValidationError => e
          render json: { errors: e.errors }, status: :unprocessable_entity
        end

        def update
          result = Api::V1::Users::Tags::UpdateService.new(
            user: current_user,
            id: params[:id],
            params: update_params
          ).call
          unless result[:success]
            return render json: { error: result[:error] }, status: :not_found
          end

          render json: result[:data], status: :ok
        rescue BaseService::ValidationError => e
          render json: { errors: e.errors }, status: :unprocessable_entity
        end

        def destroy
          result = Api::V1::Users::Tags::DestroyService.new(
            user: current_user,
            id: params[:id]
          ).call
          unless result[:success]
            return render json: { error: result[:error] }, status: :not_found
          end

          head :no_content
        rescue BaseService::ValidationError => e
          render json: { errors: e.errors }, status: :unprocessable_entity
        end

        def transactions
          tag = tag_for_current_user
          return render json: { error: "Tag not found" }, status: :not_found unless tag

          result = Api::V1::Users::Tags::TransactionsIndexService.new(
            user: current_user,
            tag: tag,
            params: transactions_index_params
          ).call

          rows = ::Api::V1::Users::Transactions::IndexPayload.call(result[:transactions])
          render json: {
            id: result[:tag_id],
            name: result[:tag_name],
            created_at: result[:tag_created_at],
            transactions: rows[:transactions]
          }, status: :ok
        rescue BaseService::ValidationError => e
          render json: { errors: e.errors }, status: :unprocessable_entity
        end

        private

        def tag_for_current_user
          account = current_user.account
          return nil unless account

          account.tags.find_by(id: params[:id])
        end

        def transactions_index_params
          params.permit(:currency, :start_date, :end_date).to_h.deep_symbolize_keys
        end

        def index_params
          params.permit(:created_by, :include_tagged_transactions_count).to_h.deep_symbolize_keys
        end

        def create_params
          params.permit(:name).to_h.deep_symbolize_keys
        end

        def update_params
          params.permit(:name).to_h.deep_symbolize_keys
        end

        def authorize_user!
          return if params[:user_id].to_s == current_user.id.to_s

          render json: { error: "Forbidden" }, status: :forbidden
        end
      end
    end
  end
end
