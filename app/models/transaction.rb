# frozen_string_literal: true

class Transaction < ApplicationRecord
  belongs_to :user, optional: false
  has_many :images,
    class_name: "Transaction::Image",
    foreign_key: :transaction_id,
    dependent: :destroy,
    inverse_of: :transaction_record

  has_many :positions,
    class_name: "Transaction::Position",
    foreign_key: :transaction_id,
    dependent: :destroy,
    inverse_of: :transaction_record

  has_many :vat_components,
    class_name: "Transaction::VatComponent",
    foreign_key: :transaction_id,
    dependent: :destroy,
    inverse_of: :transaction_record

  enum :status, {
    in_progress: 0,
    ready: 1,
    failed: 2
  }

  validates :amount, numericality: true, allow_nil: true
  validates :total_vat, numericality: true, allow_nil: true

  def image_urls
    urls = images.map(&:image_url)
    return urls if urls.any?
    return [] if receipt_image_url.blank?

    [ receipt_image_url ]
  end
end
