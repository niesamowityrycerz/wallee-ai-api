# frozen_string_literal: true

module Api
  module V1
    module Users
      module Transactions
        module Positions
          class UpdateContract < Dry::Validation::Contract
            params do
              optional(:name).filled(:string)
              optional(:quantity).filled(:float)
              optional(:unit_price).filled(:float)
              optional(:total_discount).maybe(:float)
              optional(:category).filled(:string)
            end

            rule do
              base.failure("at least one field must be provided") if values.to_h.empty?
            end

            rule(:quantity) do
              next unless key? && value

              key.failure("must be greater than 0") unless value.positive?
            end

            rule(:category) do
              next unless key? && value

              unless Transaction::Position::CATEGORIES.include?(value)
                key.failure("must be one of: #{Transaction::Position::CATEGORIES.join(", ")}")
              end
            end
          end
        end
      end
    end
  end
end
