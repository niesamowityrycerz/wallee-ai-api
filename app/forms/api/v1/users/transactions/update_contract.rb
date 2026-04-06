# frozen_string_literal: true

module Api
  module V1
    module Users
      module Transactions
        class UpdateContract < Dry::Validation::Contract
          CURRENCIES = %w[pln usd eur gbp].freeze

          params do
            optional(:name).filled(:string)
            optional(:amount).filled(:float)
            optional(:currency).filled(:string)
            optional(:transaction_date).filled(:date)
            optional(:store_name).maybe(:string)
            optional(:store_address).maybe(:string)
            optional(:total_discount).maybe(:float)
          end

          rule do
            base.failure("at least one field must be provided") if values.to_h.empty?
          end

          rule(:currency) do
            next unless key? && value

            key.failure("must be one of: #{CURRENCIES.join(", ")}") unless CURRENCIES.include?(value)
          end
        end
      end
    end
  end
end
