# frozen_string_literal: true

module Api
  module V1
    module Users
      module UserSettings
        class ShowService
          attr_reader :user

          def initialize(user:)
            @user = user
          end

          def call
            setting = user.user_setting
            { success: true, data: serialize(setting) }
          end

          private

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
