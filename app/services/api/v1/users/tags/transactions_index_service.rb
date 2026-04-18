# frozen_string_literal: true

module Api
  module V1
    module Users
      module Tags
        class TransactionsIndexService < BaseService
          def initialize(user:, tag:, params:)
            @user = user
            @tag = tag
            @params = params
          end

          def call
            validated = validate(contract, params)
            txs = filtered_transactions(validated)
            {
              success: true,
              tag_id: tag.id,
              tag_name: tag.name,
              tag_created_at: tag.created_at,
              transactions: txs
            }
          end

          private

          attr_reader :user, :tag, :params

          def contract
            @contract ||= ::Api::V1::Users::Tags::TransactionsIndexContract.new
          end

          def filtered_transactions(validated)
            scope = base_scope
            scope = apply_currency_filter(scope, validated)
            scope = apply_date_filter(scope, validated)
            scope.distinct.order(transaction_date: :desc, created_at: :desc)
          end

          def base_scope
            user.transactions
              .joins(:transaction_tags)
              .where(transaction_tags: { tag_id: tag.id })
              .includes(:images)
          end

          def apply_currency_filter(scope, validated)
            c = validated[:currency].to_s.strip
            return scope if c.empty?

            scope.where(currency: c)
          end

          def apply_date_filter(scope, validated)
            start_s = validated[:start_date].to_s.strip
            end_s = validated[:end_date].to_s.strip
            return scope if start_s.empty? || end_s.empty?

            fmt = ::Api::V1::Users::Tags::TransactionsIndexContract::DATE_FORMAT
            start_d = Date.strptime(start_s, fmt)
            end_d = Date.strptime(end_s, fmt)
            scope.where(transaction_date: start_d..end_d)
          end
        end
      end
    end
  end
end
