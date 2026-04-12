# frozen_string_literal: true

module Api
  module V1
    module Users
      module UserSettings
        class UpdateService < BaseService
          UPDATABLE_FIELDS = %i[currency show_vat_details].freeze

          def initialize(user:, params:)
            @user = user
            @params = params
          end

          def call
            setting = user.user_setting
            validated = validate(contract, params)
            attrs = slice_present(validated)
            setting.update!(attrs)

            { success: true, data: serialize(setting) }
          end

          private

          attr_reader :user, :params

          def contract
            @contract ||= ::Api::V1::Users::UserSettings::UpdateContract.new
          end

          def slice_present(validated)
            UPDATABLE_FIELDS.each_with_object({}) do |key, acc|
              acc[key] = validated[key] if validated.key?(key)
            end
          end

          def serialize(setting)
            {
              currency: setting.currency,
              show_vat_details: setting.show_vat_details,
              updated_at: setting.updated_at
            }
          end
        end
      end
    end
  end
end
