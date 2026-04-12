# frozen_string_literal: true

class CreateUserSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :user_settings do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :currency, null: false, default: "PLN"
      t.boolean :show_vat_details, null: false, default: false
      t.timestamps
    end
  end
end
