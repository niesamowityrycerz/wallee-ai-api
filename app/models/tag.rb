# frozen_string_literal: true

class Tag < ApplicationRecord
  SYSTEM_DEFAULT_NAMES = [
    "Groceries",
    "Dining out",
    "Coffee & snacks",
    "Transport & fuel",
    "Shopping & retail",
    "Health & pharmacy",
    "Entertainment",
    "Subscriptions & software",
    "Home & household",
    "Utilities",
    "Travel & lodging",
    "Personal care",
    "Kids & family",
    "Pets",
    "Gifts & charity"
  ].freeze

  belongs_to :account
  has_many :transaction_tags, dependent: :delete_all
  has_many :transactions, through: :transaction_tags, source: :transaction_record

  enum :created_by, { account_member: 0, llm: 1 }

  validates :name, presence: true
end
