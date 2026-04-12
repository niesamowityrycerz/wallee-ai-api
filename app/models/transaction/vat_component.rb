# frozen_string_literal: true

class Transaction::VatComponent < ApplicationRecord
  self.table_name = "transaction_vat_components"

  VAT_GROUPS = %w[A B C D E].freeze

  belongs_to :transaction_record,
    class_name: "Transaction",
    foreign_key: :transaction_id,
    inverse_of: :vat_components,
    optional: false

  validates :vat_group, presence: true, inclusion: { in: VAT_GROUPS }
  validates :rate_percent, presence: true, numericality: true
  validates :vat_amount, presence: true, numericality: true
end
