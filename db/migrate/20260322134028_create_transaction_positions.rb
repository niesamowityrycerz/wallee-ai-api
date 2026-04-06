# frozen_string_literal: true

class CreateTransactionPositions < ActiveRecord::Migration[8.1]
  def change
    create_table :transaction_positions do |t|
      t.references :transaction, null: false, foreign_key: true
      t.string :name, null: false
      t.decimal :quantity, precision: 10, scale: 3, null: false
      t.decimal :unit_price, precision: 12, scale: 2, null: false
      t.string :category, null: false
      t.decimal :total_discount, precision: 12, scale: 2, default: 0

      t.timestamps
    end
  end
end
