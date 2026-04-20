# frozen_string_literal: true

module Api
  module V1
    module Users
      module Analytics
        class SpendingService < BaseService
          def initialize(user:, params:)
            @user = user
            @params = params
          end

          def call
            validated = validate(contract, @params)
            range = date_range(validated)
            sums = daily_amounts(validated[:currency], range)
            payload(validated[:currency], range, sums)
          end

          private

          attr_reader :user, :params

          def contract
            @contract ||= ::Api::V1::Users::Transactions::IndexContract.new
          end

          def date_range(validated)
            fmt = ::Api::V1::Users::Transactions::IndexContract::DATE_FORMAT
            start_d = Date.strptime(validated[:start_date], fmt)
            end_d = Date.strptime(validated[:end_date], fmt)
            start_d..end_d
          end

          def daily_amounts(currency, range)
            ::Transactions::SpendingTransactionsRelation
              .call(user: user, from_date: range.begin, to_date: range.end, currency: currency)
              .group(:transaction_date)
              .sum(:amount)
          end

          def payload(currency, range, sums)
            {
              currency: currency,
              start_date: range.begin.iso8601,
              end_date: range.end.iso8601,
              points: points(range, sums)
            }
          end

          def points(range, sums)
            range.each.map { |day| { date: day.iso8601, total: day_total(sums, day) } }
          end

          def day_total(sums, day)
            (sums[day] || 0).to_f
          end
        end
      end
    end
  end
end
