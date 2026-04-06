# frozen_string_literal: true

class Transaction::Position < ApplicationRecord
  self.table_name = "transaction_positions"

  CATEGORIES = [
    "groceries",
    "beverages",
    "dairy",
    "bakery",
    "meat_and_seafood",
    "fruits_and_vegetables",
    "snacks_and_sweets",
    "frozen_foods",
    "household_and_cleaning",
    "personal_care",
    "health_and_pharmacy",
    "electronics",
    "clothing_and_apparel",
    "alcohol_and_tobacco",
    "pet_supplies",
    "office_supplies",
    "home_and_garden",
    "toys_and_games",
    "books_and_magazines",
    "restaurant_and_dining",
    "transportation",
    "entertainment",
    "other"
  ].freeze

  belongs_to :transaction_record,
    class_name: "Transaction",
    foreign_key: :transaction_id,
    inverse_of: :positions,
    optional: false

  validates :name, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: true
  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validates :total_price, numericality: true

  def self.total_price_for(quantity:, unit_price:, total_discount:)
    discount = total_discount.nil? ? 0.to_d : total_discount.to_d
    (quantity.to_d * unit_price.to_d) - discount
  end
end
