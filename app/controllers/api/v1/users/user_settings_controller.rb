# frozen_string_literal: true

module Api
  module V1
    module Users
      class UserSettingsController < ApplicationController
        before_action :authorize_user!

        def show
          result = Api::V1::Users::UserSettings::ShowService.new(user: current_user).call
          render json: result[:data], status: :ok
        end

        def update
          result = Api::V1::Users::UserSettings::UpdateService.new(
            user: current_user,
            params: update_params
          ).call

          render json: result[:data], status: :ok
        rescue BaseService::ValidationError => e
          render json: { errors: e.errors }, status: :unprocessable_entity
        end

        private

        def update_params
          params.permit(:currency, :show_vat_details).to_h.deep_symbolize_keys
        end

        def authorize_user!
          return if params[:user_id].to_s == current_user.id.to_s

          render json: { error: "Forbidden" }, status: :forbidden
        end
      end
    end
  end
end
