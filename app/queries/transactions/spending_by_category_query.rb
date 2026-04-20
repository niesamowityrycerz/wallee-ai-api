# frozen_string_literal: true

module Transactions
  class SpendingByCategoryQuery
    SEGMENTS_SQL = <<~SQL.squish.freeze
      SELECT transaction_positions.category AS category,
             SUM(transaction_positions.total_price) AS total,
             COUNT(DISTINCT transactions.id) AS transaction_count
      FROM transaction_positions
      INNER JOIN transactions ON transactions.id = transaction_positions.transaction_id
      WHERE transactions.user_id = ?
        AND transactions.status = ?
        AND transactions.currency = ?
        AND transactions.transaction_date BETWEEN ? AND ?
        AND transactions.amount IS NOT NULL
        AND transaction_positions.category IN (?)
      GROUP BY transaction_positions.category
    SQL

    def initialize(user:, from_date:, to_date:, currency:, categories:)
      @user = user
      @from_date = from_date
      @to_date = to_date
      @currency = currency
      @categories = categories
    end

    def segment_rows
      Transaction.connection.select_all(segment_sql).map { |r| serialize_segment(r) }
    end

    private

    attr_reader :user, :from_date, :to_date, :currency, :categories

    def segment_sql
      Transaction.sanitize_sql_array(
        [
          SEGMENTS_SQL,
          user.id,
          Transaction.statuses[:ready],
          currency,
          from_date,
          to_date,
          categories
        ]
      )
    end

    def serialize_segment(row)
      {
        category: row["category"],
        total: row["total"].to_f,
        transaction_count: row["transaction_count"].to_i
      }
    end
  end
end
