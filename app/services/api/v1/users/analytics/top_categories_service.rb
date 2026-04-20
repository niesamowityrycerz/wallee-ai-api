# frozen_string_literal: true

module Api
  module V1
    module Users
      module Analytics
        class TopCategoriesService
          WINDOW_DAYS = 90

          def initialize(user:)
            @user = user
          end

          def call
            to_d = Date.current
            from_d = to_d - (WINDOW_DAYS - 1)
            rows = ::Transactions::TopPositionCategoriesQuery.new(
              user: user,
              from_date: from_d,
              to_date: to_d
            ).rows

            {
              as_of: to_d.iso8601,
              period_days: WINDOW_DAYS,
              categories: rows
            }
          end

          private

          attr_reader :user
        end
      end
    end
  end
end
