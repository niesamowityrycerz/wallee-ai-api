# frozen_string_literal: true

module Api
  module V1
    module Users
      module Analytics
        class GrossSpendingService < BaseService
          def initialize(user:, params:)
            @user = user
            @params = params
          end

          def call
            validated = validate(contract, @params)
            range = date_range(validated)
            totals = daily_totals(validated[:currency], range)
            payload(validated[:currency], range, totals)
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

          def daily_totals(currency, range)
            rows = gross_scope(currency, range).group(:transaction_date).pluck(
              :transaction_date,
              Arel.sql("SUM(amount)"),
              Arel.sql("SUM(COALESCE(total_vat, 0))"),
              Arel.sql("SUM(amount - COALESCE(total_vat, 0))")
            )
            rows.index_by(&:first).transform_values { |(_, g, v, n)| triple(g, v, n) }
          end

          def gross_scope(currency, range)
            ::Transactions::GrossSpendingTransactionsRelation.call(
              user: user,
              from_date: range.begin,
              to_date: range.end,
              currency: currency
            )
          end

          def triple(gross, vat, net)
            {
              gross_total: gross.to_f,
              vat_total: vat.to_f,
              net_total: net.to_f
            }
          end

          def payload(currency, range, totals)
            {
              currency: currency,
              start_date: range.begin.iso8601,
              end_date: range.end.iso8601,
              points: points(range, totals)
            }
          end

          def points(range, totals)
            range.each.map { |day| point_for_day(day, totals) }
          end

          def point_for_day(day, totals)
            t = totals[day] || zero_triple
            {
              date: day.iso8601,
              net_total: t[:net_total],
              vat_total: t[:vat_total],
              gross_total: t[:gross_total]
            }
          end

          def zero_triple
            { net_total: 0.0, vat_total: 0.0, gross_total: 0.0 }
          end
        end
      end
    end
  end
end
