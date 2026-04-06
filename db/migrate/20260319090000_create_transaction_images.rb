# frozen_string_literal: true

class CreateTransactionImages < ActiveRecord::Migration[8.1]
  def change
    create_table :transaction_images do |t|
      t.references :transaction, null: false, foreign_key: true
      t.string :image_url, null: false

      t.timestamps
    end
  end
end
