# frozen_string_literal: true

module Api
  module V1
    module Users
      module Tags
        class UpdateContract < Dry::Validation::Contract
          params do
            required(:name).filled(:string)
          end

          rule(:name) do
            key.failure("can't be blank") if value.strip.empty?
          end
        end
      end
    end
  end
end
