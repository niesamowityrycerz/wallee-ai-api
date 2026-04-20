# frozen_string_literal: true

class CategoryPieConfig < ApplicationRecord
  MAX_CATEGORIES = 7
  MIN_CATEGORIES = 1
  MAX_CONFIGS_PER_USER = 3

  belongs_to :user, inverse_of: :category_pie_configs

  validates :name, presence: true
  validate :categories_valid

  private

  def categories_valid
    cats = categories || []
    if cats.blank?
      errors.add(:categories, "can't be blank")
      return
    end
    if cats.uniq.length != cats.length
      errors.add(:categories, "must be unique")
      return
    end
    unless (MIN_CATEGORIES..MAX_CATEGORIES).cover?(cats.length)
      errors.add(:categories, "must have between #{MIN_CATEGORIES} and #{MAX_CATEGORIES} items")
      return
    end

    invalid = cats - Transaction::Position::CATEGORIES
    return if invalid.empty?

    errors.add(:categories, "contains unknown categories: #{invalid.join(', ')}")
  end
end
