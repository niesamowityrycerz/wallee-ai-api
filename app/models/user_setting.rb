# frozen_string_literal: true

class UserSetting < ApplicationRecord
  DEFAULT_CURRENCY = "PLN"
  CURRENCIES = %w[PLN EUR USD GBP].freeze

  belongs_to :user, inverse_of: :user_setting

  validates :currency, presence: true, inclusion: { in: CURRENCIES }
  validates :show_vat_details, inclusion: { in: [ true, false ] }
end
