# frozen_string_literal: true

module Api
  module V1
    module Users
      module Analytics
        module CategoryPieConfigs
          class UpdateContract < Dry::Validation::Contract
            params do
              optional(:name).maybe(:string)
              optional(:categories).maybe(:array)
            end

            rule do
              unless key?(:name) || key?(:categories)
                key(:base).failure("at least one of name, categories must be present")
              end
            end

            rule(:name) do
              next unless key?(:name)
              next if value.nil?

              key.failure("can't be blank") if value.to_s.strip.empty?
            end

            rule(:categories) do
              next unless key?(:categories)
              if value.nil?
                key.failure("can't be nil")
                next
              end

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
