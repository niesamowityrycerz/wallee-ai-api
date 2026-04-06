# frozen_string_literal: true

class AddReceiptImageUrlToTransactions < ActiveRecord::Migration[8.1]
  def change
    add_column :transactions, :receipt_image_url, :string
  end
end
