# frozen_string_literal: true

class Account < ApplicationRecord
  DEFAULT_NAME = "Personal"

  has_many :users, inverse_of: :account
  has_many :tags, dependent: :destroy

  after_create_commit :seed_default_tags

  private

  def seed_default_tags
    Accounts::SeedDefaultTags.new(account: self).call
  end
end
