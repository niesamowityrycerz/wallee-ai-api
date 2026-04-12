# frozen_string_literal: true

module Api
  module V1
    module Users
      module UserSettings
        class UpdateContract < Dry::Validation::Contract
          params do
            optional(:currency).filled(:string, included_in?: UserSetting::CURRENCIES)
            optional(:show_vat_details).filled(:bool)
          end

          rule do
            base.failure("at least one field must be provided") if values.to_h.empty?
          end
        end
      end
    end
  end
end
