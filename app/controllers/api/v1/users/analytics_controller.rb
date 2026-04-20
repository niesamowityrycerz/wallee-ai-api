# frozen_string_literal: true

module Api
  module V1
    module Users
      class AnalyticsController < ApplicationController
        before_action :authorize_user!

        def spending
          result = Api::V1::Users::Analytics::SpendingService.new(
            user: current_user,
            params: analytics_params
          ).call
          render json: result, status: :ok
        rescue BaseService::ValidationError => e
          render json: { errors: e.errors }, status: :unprocessable_entity
        end

        def gross_spending
          unless current_user.user_setting&.show_vat_details
            render json: { error: "Forbidden" }, status: :forbidden
            return
          end

          result = Api::V1::Users::Analytics::GrossSpendingService.new(
            user: current_user,
            params: analytics_params
          ).call
          render json: result, status: :ok
        rescue BaseService::ValidationError => e
          render json: { errors: e.errors }, status: :unprocessable_entity
        end

        def spending_by_tag
          result = Api::V1::Users::Analytics::SpendingByTagService.new(
            user: current_user,
            params: analytics_params
          ).call
          render json: result, status: :ok
        rescue BaseService::ValidationError => e
          render json: { errors: e.errors }, status: :unprocessable_entity
        end

        def spending_by_category
          result = Api::V1::Users::Analytics::SpendingByCategoryService.new(
            user: current_user,
            params: spending_by_category_params
          ).call
          render json: result, status: :ok
        rescue ActiveRecord::RecordNotFound
          render json: { error: "Category pie config not found" }, status: :not_found
        rescue BaseService::ValidationError => e
          render json: { errors: e.errors }, status: :unprocessable_entity
        end

        def top_categories
          result = Api::V1::Users::Analytics::TopCategoriesService.new(user: current_user).call
          render json: result, status: :ok
        end

        private

        def analytics_params
          params.permit(:currency, :start_date, :end_date).to_h.deep_symbolize_keys
        end

        def spending_by_category_params
          params.permit(:currency, :start_date, :end_date, :category_pie_config_id).to_h.deep_symbolize_keys
        end

        def authorize_user!
          return if params[:user_id].to_s == current_user.id.to_s

          render json: { error: "Forbidden" }, status: :forbidden
        end
      end
    end
  end
end
