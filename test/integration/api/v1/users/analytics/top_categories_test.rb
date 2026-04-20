# frozen_string_literal: true

require "test_helper"

class Api::V1::Users::Analytics::TopCategoriesTest < ActionDispatch::IntegrationTest
  test "returns top categories by position count in last 90 days" do
    travel_to Date.new(2026, 4, 20) do
      user = create_user("top-cat")
      headers = user.create_new_auth_token
      in_window = Date.new(2026, 1, 21)
      before_window = Date.new(2026, 1, 20)

      tx_in = user.transactions.create!(
        name: "In",
        amount: 50.0,
        currency: "PLN",
        transaction_date: in_window,
        status: :ready
      )
      tx_in.positions.create!(name: "A", category: "dairy", quantity: 1, unit_price: 10, total_price: 10)
      tx_in.positions.create!(name: "B", category: "dairy", quantity: 1, unit_price: 5, total_price: 5)

      tx_old = user.transactions.create!(
        name: "Old",
        amount: 40.0,
        currency: "PLN",
        transaction_date: before_window,
        status: :ready
      )
      tx_old.positions.create!(name: "C", category: "groceries", quantity: 1, unit_price: 40, total_price: 40)

      get top_categories_api_v1_user_analytics_path(user), headers: headers, as: :json

      assert_response :success
      body = JSON.parse(response.body)
      assert_equal "2026-04-20", body["as_of"]
      assert_equal 90, body["period_days"]
      cats = body["categories"]
      assert_equal 1, cats.size
      assert_equal "dairy", cats.first["category"]
      assert_equal 2, cats.first["position_count"]
    end
  end

  test "returns 403 when user_id does not match authenticated user" do
    user = create_user("top-cat-forbid-a")
    other = create_user("top-cat-forbid-b")
    headers = user.create_new_auth_token

    get top_categories_api_v1_user_analytics_path(other), headers: headers, as: :json

    assert_response :forbidden
  end

  private

  def create_user(prefix)
    User.create!(
      email: "#{prefix}-#{SecureRandom.hex(4)}@example.com",
      password: "password",
      password_confirmation: "password"
    )
  end
end
