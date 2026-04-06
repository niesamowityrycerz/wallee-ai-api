require "test_helper"

class TransactionTest < ActiveSupport::TestCase
  test "defaults status to in_progress" do
    transaction = create_transaction

    assert_equal "in_progress", transaction.status
  end

  private

  def create_transaction
    user = User.create!(
      email: "transaction-#{SecureRandom.hex(4)}@example.com",
      password: "password",
      password_confirmation: "password"
    )

    user.transactions.create!(
      name: "Test",
      amount: 10.0,
      currency: "USD",
      transaction_date: Date.current
    )
  end
end
