# frozen_string_literal: true

class Transaction::Image < ApplicationRecord
  belongs_to :transaction_record,
    class_name: "Transaction",
    foreign_key: :transaction_id,
    inverse_of: :images,
    optional: false

  validates :image_url, presence: true
end
