# frozen_string_literal: true

module Api
  module V1
    module Users
      module Analytics
        class CategoryPieConfigsController < ApplicationController
          before_action :authorize_user!

          def index
            result = ::Api::V1::Users::Analytics::CategoryPieConfigs::IndexService.new(
              user: current_user
            ).call
            render json: result, status: :ok
          end

          def create
            result = ::Api::V1::Users::Analytics::CategoryPieConfigs::CreateService.new(
              user: current_user,
              params: config_params
            ).call
            render json: result[:data], status: :created
          rescue BaseService::ValidationError => e
            render json: { errors: e.errors }, status: :unprocessable_entity
          end

          def update
            result = ::Api::V1::Users::Analytics::CategoryPieConfigs::UpdateService.new(
              user: current_user,
              id: params[:id],
              params: config_params
            ).call
            unless result[:success]
              return render json: { error: result[:error] }, status: :not_found
            end

            render json: result[:data], status: :ok
          rescue BaseService::ValidationError => e
            render json: { errors: e.errors }, status: :unprocessable_entity
          end

          def destroy
            result = ::Api::V1::Users::Analytics::CategoryPieConfigs::DestroyService.new(
              user: current_user,
              id: params[:id]
            ).call
            unless result[:success]
              return render json: { error: result[:error] }, status: :not_found
            end

            head :no_content
          end

          private

          def config_params
            params.permit(:name, categories: []).to_h.deep_symbolize_keys
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
