# frozen_string_literal: true

module Api
  module V1
    module Users
      module Analytics
        class SpendingByTagService < BaseService
          def initialize(user:, params:)
            @user = user
            @params = params
          end

          def call
            validated = validate(contract, @params)
            account = require_account!
            range = date_range(validated)
            query = build_query(account.id, validated[:currency], range)
            build_payload(validated[:currency], range, query)
          end

          private

          attr_reader :user, :params

          def contract
            @contract ||= ::Api::V1::Users::Transactions::IndexContract.new
          end

          def require_account!
            user.account || raise(ValidationError.new({ account: [ "is required" ] }))
          end

          def date_range(validated)
            fmt = ::Api::V1::Users::Transactions::IndexContract::DATE_FORMAT
            start_d = Date.strptime(validated[:start_date], fmt)
            end_d = Date.strptime(validated[:end_date], fmt)
            start_d..end_d
          end

          def build_query(account_id, currency, range)
            ::Transactions::SpendingByTagQuery.new(
              user: user,
              account_id: account_id,
              from_date: range.begin,
              to_date: range.end,
              currency: currency
            )
          end

          def build_payload(currency, range, query)
            {
              currency: currency,
              start_date: range.begin.iso8601,
              end_date: range.end.iso8601,
              segments: query.segments,
              untagged_total: query.untagged_total,
              untagged_transaction_count: query.untagged_transaction_count
            }
          end
        end
      end
    end
  end
end
