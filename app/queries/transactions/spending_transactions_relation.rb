# frozen_string_literal: true

module Transactions
  class SpendingTransactionsRelation
    def self.call(user:, from_date:, to_date:, currency:)
      Transaction
        .where(user: user, status: :ready, currency: currency, transaction_date: from_date..to_date)
        .where.not(amount: nil)
    end
  end
end
