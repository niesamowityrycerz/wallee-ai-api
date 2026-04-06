# frozen_string_literal: true

class CreateTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.string :currency, null: false
      t.date :transaction_date, null: false
      t.string :store_name

      t.timestamps
    end

    add_index :transactions, [:user_id, :transaction_date]
  end
end
