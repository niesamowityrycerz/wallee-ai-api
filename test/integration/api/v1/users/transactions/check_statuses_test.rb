require "test_helper"

class CheckStatusesTest < ActionDispatch::IntegrationTest
  test "returns statuses for the current users transactions" do
    user = create_user("check-statuses")
    other_user = create_user("someone-else")
    first_transaction = create_transaction_for(user, :in_progress)
    second_transaction = create_transaction_for(user, :ready)
    create_transaction_for(other_user, :failed)

    post check_statuses_path(user),
      params: { ids: [ second_transaction.id, first_transaction.id ] },
      headers: user.create_new_auth_token,
      as: :json

    assert_response :success
    assert_equal(
      {
        "transactions" => [
          { "id" => second_transaction.id, "status" => "ready" },
          { "id" => first_transaction.id, "status" => "in_progress" }
        ]
      },
      JSON.parse(response.body)
    )
  end

  private

  def check_statuses_path(user)
    "/api/v1/users/#{user.id}/transactions/check_statuses"
  end

  def create_user(prefix)
    User.create!(
      email: "#{prefix}-#{SecureRandom.hex(4)}@example.com",
      password: "password",
      password_confirmation: "password"
    )
  end

  def create_transaction_for(user, status)
    user.transactions.create!(
      name: "Test",
      amount: 10.0,
      currency: "USD",
      transaction_date: Date.current,
      status: status
    )
  end
end
