# frozen_string_literal: true

module Transactions
  class SpendingSummaryQuery
    def initialize(user:, from_date:, to_date:, currency:)
      @user = user
      @from_date = from_date
      @to_date = to_date
      @currency = currency
    end

    def call
      base_scope.group(:currency).sum(:amount)
    end

    def count
      base_scope.count
    end

    def total_vat_sum
      base_scope.pick(Arel.sql("COALESCE(SUM(total_vat), 0)")) || 0
    end

    private

    attr_reader :user, :from_date, :to_date, :currency

    def base_scope
      SpendingTransactionsRelation.call(
        user: user,
        from_date: from_date,
        to_date: to_date,
        currency: currency
      )
    end
  end
end
