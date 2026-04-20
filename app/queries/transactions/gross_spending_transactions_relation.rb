# frozen_string_literal: true

module Transactions
  class GrossSpendingTransactionsRelation
    def self.call(user:, from_date:, to_date:, currency:)
      SpendingTransactionsRelation.call(
        user: user,
        from_date: from_date,
        to_date: to_date,
        currency: currency
      ).where(id: Transaction::VatComponent.select(:transaction_id))
    end
  end
end
