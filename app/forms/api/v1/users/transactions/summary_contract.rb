# frozen_string_literal: true

module Api
  module V1
    module Users
      module Transactions
        class SummaryContract < Dry::Validation::Contract
          CURRENCIES = %w[PLN USD EUR GBP].freeze
          DATE_FORMAT = "%d-%m-%Y"

          params do
            required(:currency).filled(:string)
            required(:from_date).filled(:string)
            required(:to_date).filled(:string)
          end

          rule(:currency) do
            if value != value.upcase
              key.failure("must be uppercase")
              next
            end
            key.failure("must be one of: #{CURRENCIES.join(", ")}") unless CURRENCIES.include?(value)
          end

          rule(:from_date) do
            key.failure("must be in DD-MM-YYYY format") if parse_date(value).nil?
          end

          rule(:to_date) do
            key.failure("must be in DD-MM-YYYY format") if parse_date(value).nil?
          end

          rule(:from_date, :to_date) do
            from_d = parse_date(values[:from_date])
            to_d = parse_date(values[:to_date])
            next if from_d.nil? || to_d.nil?

            key(:to_date).failure("must be greater than or equal to from_date") if to_d < from_d
          end

          private

          def parse_date(str)
            Date.strptime(str, DATE_FORMAT)
          rescue ArgumentError, TypeError
            nil
          end
        end
      end
    end
  end
end
