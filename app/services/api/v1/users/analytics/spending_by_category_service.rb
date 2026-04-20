# frozen_string_literal: true

module Api
  module V1
    module Users
      module Analytics
        class SpendingByCategoryService < BaseService
          def initialize(user:, params:)
            @user = user
            @params = params
          end

          def call
            validated = validate(contract, @params)
            config = user.category_pie_configs.find(validated[:category_pie_config_id].to_i)
            range = date_range(validated)
            rows = build_segment_rows(validated[:currency], range, config.categories)
            segments = merge_and_sort(rows, config.categories)
            payload(config.id, validated[:currency], range, segments)
          end

          private

          attr_reader :user, :params

          def contract
            @contract ||= ::Api::V1::Users::Analytics::SpendingByCategoryContract.new
          end

          def date_range(validated)
            fmt = ::Api::V1::Users::Transactions::IndexContract::DATE_FORMAT
            Date.strptime(validated[:start_date], fmt)..Date.strptime(validated[:end_date], fmt)
          end

          def build_segment_rows(currency, range, categories)
            ::Transactions::SpendingByCategoryQuery.new(
              user: user,
              from_date: range.begin,
              to_date: range.end,
              currency: currency,
              categories: categories
            ).segment_rows
          end

          def merge_and_sort(rows, ordered_categories)
            by_cat = rows.index_by { |r| r[:category] }
            merged = ordered_categories.map do |cat|
              row = by_cat[cat]
              row || { category: cat, total: 0.0, transaction_count: 0 }
            end
            merged.sort_by { |s| -s[:total] }
          end

          def payload(config_id, currency, range, segments)
            {
              currency: currency,
              start_date: range.begin.iso8601,
              end_date: range.end.iso8601,
              category_pie_config_id: config_id,
              segments: segments
            }
          end
        end
      end
    end
  end
end
