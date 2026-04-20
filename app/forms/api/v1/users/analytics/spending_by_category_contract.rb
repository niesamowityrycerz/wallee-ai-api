# frozen_string_literal: true

module Api
  module V1
    module Users
      module Analytics
        class SpendingByCategoryContract < Dry::Validation::Contract
          CURRENCIES = ::Api::V1::Users::Transactions::IndexContract::CURRENCIES
          DATE_FORMAT = ::Api::V1::Users::Transactions::IndexContract::DATE_FORMAT

          params do
            required(:currency).filled(:string)
            required(:start_date).filled(:string)
            required(:end_date).filled(:string)
            required(:category_pie_config_id).filled
          end

          rule(:currency) do
            if value != value.upcase
              key.failure("must be uppercase")
              next
            end
            key.failure("must be one of: #{CURRENCIES.join(", ")}") unless CURRENCIES.include?(value)
          end

          rule(:start_date) do
            key.failure("must be in DD-MM-YYYY format") if parse_date(value).nil?
          end

          rule(:end_date) do
            key.failure("must be in DD-MM-YYYY format") if parse_date(value).nil?
          end

          rule(:start_date, :end_date) do
            start_d = parse_date(values[:start_date])
            end_d = parse_date(values[:end_date])
            next if start_d.nil? || end_d.nil?

            key(:end_date).failure("must be greater than or equal to start_date") if end_d < start_d
          end

          rule(:category_pie_config_id) do
            unless value.to_s.match?(/\A[1-9]\d*\z/)
              key.failure("must be a positive integer")
            end
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
