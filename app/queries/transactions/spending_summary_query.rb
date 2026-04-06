# frozen_string_literal: true

module Transactions
  class SpendingSummaryQuery
    def initialize(user:, from_date:, to_date:)
      @user = user
      @from_date = from_date
      @to_date = to_date
    end

    def call
      base_scope.group(:currency).sum(:amount)
    end

    def count
      base_scope.count
    end

    private

    attr_reader :user, :from_date, :to_date

    def base_scope
      Transaction
        .where(user: user, status: :ready, transaction_date: from_date..to_date)
        .where.not(amount: nil)
    end
  end
end
