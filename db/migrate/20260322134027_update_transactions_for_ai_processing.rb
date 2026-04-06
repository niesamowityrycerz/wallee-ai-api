# frozen_string_literal: true

class UpdateTransactionsForAiProcessing < ActiveRecord::Migration[8.1]
  def change
    change_column_null :transactions, :name, true
    change_column_null :transactions, :amount, true
    change_column_null :transactions, :currency, true
    change_column_null :transactions, :transaction_date, true

    add_column :transactions, :store_address, :string
    add_column :transactions, :total_discount, :decimal, precision: 12, scale: 2, default: 0
  end
end
