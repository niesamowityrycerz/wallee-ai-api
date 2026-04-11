# frozen_string_literal: true

module Api
  module V1
    module Users
      module Transactions
        class IndexService < BaseService
          def initialize(user:, params:)
            @user = user
            @params = params
            @transactions = nil
          end

          def call
            validated = validate(contract, @params)
            range = date_range(validated)
            @transactions = user.transactions
              .includes(:images)
              .where(currency: validated[:currency], transaction_date: range)
              .order(transaction_date: :desc, created_at: :desc)
            { success: true, transactions: transactions }
          end

          private

          attr_reader :user, :params, :transactions

          def contract
            @contract ||= ::Api::V1::Users::Transactions::IndexContract.new
          end

          def date_range(validated)
            fmt = IndexContract::DATE_FORMAT
            start_d = Date.strptime(validated[:start_date], fmt)
            end_d = Date.strptime(validated[:end_date], fmt)
            start_d..end_d
          end
        end
      end
    end
  end
end
