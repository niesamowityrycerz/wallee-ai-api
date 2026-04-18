# frozen_string_literal: true

module Accounts
  class SeedDefaultTags
    def initialize(account:)
      @account = account
    end

    def call
      Tag::SYSTEM_DEFAULT_NAMES.each { |name| ensure_tag(name) }
    end

    private

    attr_reader :account

    def ensure_tag(name)
      return if account.tags.where("lower(name) = ?", name.downcase).exists?

      account.tags.create!(name: name, created_by: :account_member)
    rescue ActiveRecord::RecordNotUnique
      nil
    end
  end
end
