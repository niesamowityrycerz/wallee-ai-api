# frozen_string_literal: true

module Api
  module V1
    module Users
      module Transactions
        class SummaryService < BaseService
          def initialize(user:, params:)
            @user = user
            @params = params
          end

          def call
            validated = validate(contract, @params)
            range = parsed_range(validated)
            query = spending_query(validated[:currency], range)
            summary_hash(query, range, validated[:currency])
          end

          private

          attr_reader :user, :params

          def contract
            @contract ||= ::Api::V1::Users::Transactions::SummaryContract.new
          end

          def parsed_range(validated)
            fmt = SummaryContract::DATE_FORMAT
            start_d = Date.strptime(validated[:from_date], fmt)
            end_d = Date.strptime(validated[:to_date], fmt)
            start_d..end_d
          end

          def spending_query(currency, range)
            ::Transactions::SpendingSummaryQuery.new(
              user: user,
              from_date: range.begin,
              to_date: range.end,
              currency: currency
            )
          end

          def summary_hash(query, range, currency)
            {
              from_date: range.begin,
              to_date: range.end,
              currency: currency,
              transaction_count: query.count,
              totals: query.call.transform_values(&:to_f)
            }
          end
        end
      end
    end
  end
end
