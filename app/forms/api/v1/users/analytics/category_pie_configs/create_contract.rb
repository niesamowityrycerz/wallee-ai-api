# frozen_string_literal: true

module Api
  module V1
    module Users
      module Analytics
        module CategoryPieConfigs
          class CreateContract < Dry::Validation::Contract
            params do
              required(:name).filled(:string)
              required(:categories).array(:string)
            end

            rule(:categories) do
              cats = value.uniq
              unless (1..7).cover?(cats.size)
                key.failure("must have between 1 and 7 items")
                next
              end
              if cats.size != value.size
                key.failure("must have unique values")
                next
              end

              invalid = cats - ::Transaction::Position::CATEGORIES
              key.failure("must only include valid categories") unless invalid.empty?
            end
          end
        end
      end
    end
  end
end
