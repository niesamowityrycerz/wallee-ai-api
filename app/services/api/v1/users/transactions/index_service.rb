# frozen_string_literal: true

module Api
  module V1
    module Users
      module Transactions
        class IndexService
          attr_reader :user, :transactions

          def initialize(user:)
            @user = user
            @transactions = nil
          end

          def call
            @transactions = user.transactions.includes(:images)
              .order(transaction_date: :desc, created_at: :desc)
            { success: true, transactions: transactions }
          end
        end
      end
    end
  end
end
