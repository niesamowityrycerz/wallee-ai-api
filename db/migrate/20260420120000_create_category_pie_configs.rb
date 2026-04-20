# frozen_string_literal: true

class CreateCategoryPieConfigs < ActiveRecord::Migration[8.1]
  def change
    create_table :category_pie_configs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :categories, array: true, default: [], null: false

      t.timestamps
    end

    add_index :category_pie_configs, "user_id, lower((name)::text)",
              unique: true,
              name: "index_category_pie_configs_on_user_id_lower_name"
  end
end
