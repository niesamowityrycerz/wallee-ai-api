# frozen_string_literal: true

require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test "new user gets an account with fifteen seeded tags" do
    user = User.create!(
      email: "account-#{SecureRandom.hex(4)}@example.com",
      password: "password",
      password_confirmation: "password"
    )

    account = user.reload.account
    assert_not_nil account
    assert_equal Account::DEFAULT_NAME, account.name
    assert_equal 15, account.tags.count
    assert account.tags.account_member.exists?
  end
end
