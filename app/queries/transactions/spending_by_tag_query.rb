# frozen_string_literal: true

module Transactions
  class SpendingByTagQuery
    SEGMENTS_SQL = <<~SQL.squish.freeze
      SELECT tt.tag_id AS tag_id,
             tags.name AS tag_name,
             SUM(transactions.amount / denom.cnt) AS total,
             COUNT(DISTINCT transactions.id) AS transaction_count
      FROM transactions
      INNER JOIN (
        SELECT tt.transaction_id, COUNT(*)::numeric AS cnt
        FROM transaction_tags tt
        INNER JOIN tags tcount ON tcount.id = tt.tag_id AND tcount.account_id = ?
        GROUP BY tt.transaction_id
      ) denom ON denom.transaction_id = transactions.id
      INNER JOIN transaction_tags tt ON tt.transaction_id = transactions.id
      INNER JOIN tags ON tags.id = tt.tag_id AND tags.account_id = ?
      WHERE transactions.user_id = ?
        AND transactions.status = ?
        AND transactions.currency = ?
        AND transactions.transaction_date BETWEEN ? AND ?
        AND transactions.amount IS NOT NULL
      GROUP BY tt.tag_id, tags.name
      HAVING SUM(transactions.amount / denom.cnt) > 0
      ORDER BY SUM(transactions.amount / denom.cnt) DESC
    SQL

    UNTAGGED_SQL = <<~SQL.squish.freeze
      SELECT COALESCE(SUM(transactions.amount), 0) AS total,
             COUNT(*)::bigint AS transaction_count
      FROM transactions
      WHERE transactions.user_id = ?
        AND transactions.status = ?
        AND transactions.currency = ?
        AND transactions.transaction_date BETWEEN ? AND ?
        AND transactions.amount IS NOT NULL
        AND NOT EXISTS (
          SELECT 1 FROM transaction_tags tt
          WHERE tt.transaction_id = transactions.id
        )
    SQL

    def initialize(user:, account_id:, from_date:, to_date:, currency:)
      @user = user
      @account_id = account_id
      @from_date = from_date
      @to_date = to_date
      @currency = currency
    end

    def segments
      segment_rows.map { |row| serialize_segment(row) }
    end

    def untagged_total
      untagged_row["total"].to_f
    end

    def untagged_transaction_count
      untagged_row["transaction_count"].to_i
    end

    private

    attr_reader :user, :account_id, :from_date, :to_date, :currency

    def segment_rows
      Transaction.connection.select_all(segment_sql)
    end

    def segment_sql
      Transaction.sanitize_sql_array(
        [
          SEGMENTS_SQL,
          account_id,
          account_id,
          user.id,
          Transaction.statuses[:ready],
          currency,
          from_date,
          to_date
        ]
      )
    end

    def serialize_segment(row)
      {
        tag_id: row["tag_id"].to_i,
        tag_name: row["tag_name"],
        total: row["total"].to_f,
        transaction_count: row["transaction_count"].to_i
      }
    end

    def untagged_row
      @untagged_row ||= begin
        r = Transaction.connection.select_one(untagged_sql)
        r || { "total" => 0, "transaction_count" => 0 }
      end
    end

    def untagged_sql
      Transaction.sanitize_sql_array(
        [
          UNTAGGED_SQL,
          user.id,
          Transaction.statuses[:ready],
          currency,
          from_date,
          to_date
        ]
      )
    end
  end
end
