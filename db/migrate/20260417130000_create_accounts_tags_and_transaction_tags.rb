# frozen_string_literal: true

class CreateAccountsTagsAndTransactionTags < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts do |t|
      t.string :name, null: false
      t.timestamps
    end

    add_reference :users, :account, foreign_key: true

    create_table :tags do |t|
      t.references :account, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :created_by, null: false, default: 0
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          CREATE UNIQUE INDEX index_tags_on_account_id_lower_name
          ON tags (account_id, lower(name::text))
        SQL
      end
      dir.down do
        execute "DROP INDEX IF EXISTS index_tags_on_account_id_lower_name"
      end
    end

    create_table :transaction_tags do |t|
      t.references :transaction, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true
      t.integer :source, null: false, default: 0
      t.timestamps
    end

    add_index :transaction_tags, %i[transaction_id tag_id], unique: true
  end
end
