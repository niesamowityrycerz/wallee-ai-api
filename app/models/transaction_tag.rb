# frozen_string_literal: true

class TransactionTag < ApplicationRecord
  belongs_to :transaction_record,
    class_name: "Transaction",
    foreign_key: :transaction_id,
    inverse_of: :transaction_tags

  belongs_to :tag

  enum :source, { user: 0, llm: 1 }

  validates :tag_id, uniqueness: { scope: :transaction_id }
end
