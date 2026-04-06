# frozen_string_literal: true

class AddTotalPriceToTransactionPositions < ActiveRecord::Migration[8.1]
  def change
    add_column :transaction_positions, :total_price, :decimal, precision: 12, scale: 2, null: false, default: 0
  end
end
