# frozen_string_literal: true

module Transactions
  class TopPositionCategoriesQuery
    SQL = <<~SQL.squish.freeze
      SELECT transaction_positions.category AS category,
             COUNT(*)::bigint AS position_count
      FROM transaction_positions
      INNER JOIN transactions ON transactions.id = transaction_positions.transaction_id
      WHERE transactions.user_id = ?
        AND transactions.status = ?
        AND transactions.amount IS NOT NULL
        AND transactions.transaction_date BETWEEN ? AND ?
      GROUP BY transaction_positions.category
      ORDER BY position_count DESC, transaction_positions.category ASC
      LIMIT 7
    SQL

    def initialize(user:, from_date:, to_date:)
      @user = user
      @from_date = from_date
      @to_date = to_date
    end

    def rows
      Transaction.connection.select_all(sanitized_sql).map { |r| serialize(r) }
    end

    private

    attr_reader :user, :from_date, :to_date

    def sanitized_sql
      Transaction.sanitize_sql_array(
        [
          SQL,
          user.id,
          Transaction.statuses[:ready],
          from_date,
          to_date
        ]
      )
    end

    def serialize(row)
      {
        category: row["category"],
        position_count: row["position_count"].to_i
      }
    end
  end
end
