# frozen_string_literal: true

module Api
  module V1
    module Users
      module Transactions
        class SummaryService
          DEFAULT_FROM_DATE = -> { Date.current.beginning_of_month }
          DEFAULT_TO_DATE   = -> { Date.current.end_of_month }

          attr_reader :user, :from_date, :to_date

          def initialize(user:, from_date: nil, to_date: nil)
            @user      = user
            @from_date = parse_date(from_date) || DEFAULT_FROM_DATE.call
            @to_date   = parse_date(to_date)   || DEFAULT_TO_DATE.call
          end

          def call
            query = ::Transactions::SpendingSummaryQuery.new(
              user: user, from_date: from_date, to_date: to_date
            )

            {
              from_date: from_date,
              to_date: to_date,
              transaction_count: query.count,
              totals: query.call.transform_values(&:to_f)
            }
          end

          private

          def parse_date(value)
            return nil if value.blank?

            Date.parse(value.to_s)
          rescue Date::Error
            nil
          end
        end
      end
    end
  end
end
