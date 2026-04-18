# frozen_string_literal: true

module Api
  module V1
    module Users
      module Tags
        class TransactionsIndexContract < Dry::Validation::Contract
          CURRENCIES = %w[PLN USD EUR GBP].freeze
          DATE_FORMAT = "%d-%m-%Y"

          params do
            optional(:currency).maybe(:string)
            optional(:start_date).maybe(:string)
            optional(:end_date).maybe(:string)
          end

          rule(:currency) do
            next if value.nil? || value.to_s.strip.empty?

            v = value.to_s.strip
            if v != v.upcase
              key.failure("must be uppercase")
              next
            end
            key.failure("must be one of: #{CURRENCIES.join(", ")}") unless CURRENCIES.include?(v)
          end

          rule(:start_date) do
            next if value.nil? || value.to_s.strip.empty?

            key.failure("must be in DD-MM-YYYY format") if parse_date(value).nil?
          end

          rule(:end_date) do
            next if value.nil? || value.to_s.strip.empty?

            key.failure("must be in DD-MM-YYYY format") if parse_date(value).nil?
          end

          rule(:start_date, :end_date) do
            start_s = values[:start_date].to_s.strip
            end_s = values[:end_date].to_s.strip
            next if start_s.empty? && end_s.empty?
            if start_s.empty? || end_s.empty?
              base.failure("start_date and end_date must both be provided when filtering by date")
              next
            end

            start_d = parse_date(values[:start_date])
            end_d = parse_date(values[:end_date])
            next if start_d.nil? || end_d.nil?

            key(:end_date).failure("must be greater than or equal to start_date") if end_d < start_d
          end

          def parse_date(str)
            Date.strptime(str.to_s.strip, DATE_FORMAT)
          rescue ArgumentError, TypeError
            nil
          end
        end
      end
    end
  end
end
