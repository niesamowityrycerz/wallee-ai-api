# frozen_string_literal: true

module Api
  module V1
    module Users
      module Transactions
        class CreateByHandContract < Dry::Validation::Contract
          CURRENCIES = %w[PLN USD EUR GBP].freeze

          params do
            required(:title).filled(:string)
            optional(:store_name).maybe(:string)
            required(:total_price).filled(:float)
            required(:currency).filled(:string, included_in?: CURRENCIES)
            required(:transaction_date).filled(:date)
            required(:positions).array(:hash) do
              required(:name).filled(:string)
              required(:quantity).filled(:float)
              required(:price).filled(:float)
              required(:category).filled(:string)
              required(:total_discount).filled(:float)
            end
          end

          rule(:positions).each do
            next if value[:category].nil? || Transaction::Position::CATEGORIES.include?(value[:category])

            key.failure("category must be one of: #{Transaction::Position::CATEGORIES.join(", ")}")
          end

          rule(:positions).each do
            next if value[:total_discount].to_d >= 0

            key.failure("total_discount must be greater than or equal to 0")
          end
        end
      end
    end
  end
end
