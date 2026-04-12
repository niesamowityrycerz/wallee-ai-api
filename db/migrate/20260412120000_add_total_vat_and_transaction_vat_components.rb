# frozen_string_literal: true

class AddTotalVatAndTransactionVatComponents < ActiveRecord::Migration[8.1]
  def change
    add_column :transactions, :total_vat, :decimal, precision: 12, scale: 2

    create_table :transaction_vat_components do |t|
      t.references :transaction, null: false, foreign_key: true
      t.string :vat_group, null: false
      t.decimal :rate_percent, precision: 7, scale: 4, null: false
      t.decimal :vat_amount, precision: 12, scale: 2, null: false
      t.timestamps
    end

    add_index :transaction_vat_components,
      %i[transaction_id vat_group],
      unique: true,
      name: "index_transaction_vat_components_on_txn_id_and_vat_group"
  end
end
