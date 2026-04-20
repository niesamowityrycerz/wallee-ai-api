# frozen_string_literal: true

require "test_helper"

class Api::V1::Users::Analytics::SpendingTest < ActionDispatch::IntegrationTest
  test "returns daily points and fills gaps with zero" do
    user = create_user("analytics-spend")
    headers = user.create_new_auth_token
    d0 = Date.new(2026, 4, 1)
    d2 = Date.new(2026, 4, 3)
    user.transactions.create!(
      name: "A",
      amount: 10.5,
      currency: "PLN",
      transaction_date: d0,
      status: :ready
    )
    user.transactions.create!(
      name: "B",
      amount: 20,
      currency: "PLN",
      transaction_date: d2,
      status: :ready
    )

    get spending_api_v1_user_analytics_path(
      user,
      params: {
        currency: "PLN",
        start_date: "01-04-2026",
        end_date: "03-04-2026"
      }
    ),
      headers: headers,
      as: :json

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "PLN", body["currency"]
    assert_equal "2026-04-01", body["start_date"]
    assert_equal "2026-04-03", body["end_date"]
    assert_equal 3, body["points"].size
    assert_equal({ "date" => "2026-04-01", "total" => 10.5 }, body["points"][0])
    assert_equal({ "date" => "2026-04-02", "total" => 0.0 }, body["points"][1])
    assert_equal({ "date" => "2026-04-03", "total" => 20.0 }, body["points"][2])
  end

  test "only includes ready transactions with amount like summary" do
    user = create_user("analytics-spend-scope")
    headers = user.create_new_auth_token
    day = Date.new(2026, 5, 10)
    user.transactions.create!(
      name: "ready",
      amount: 100,
      currency: "EUR",
      transaction_date: day,
      status: :ready
    )
    user.transactions.create!(
      name: "progress",
      amount: 50,
      currency: "EUR",
      transaction_date: day,
      status: :in_progress
    )
    user.transactions.create!(
      name: "no amount",
      amount: nil,
      currency: "EUR",
      transaction_date: day,
      status: :ready
    )

    get spending_api_v1_user_analytics_path(
      user,
      params: {
        currency: "EUR",
        start_date: "10-05-2026",
        end_date: "10-05-2026"
      }
    ),
      headers: headers,
      as: :json

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 100.0, body["points"].first["total"]
  end

  test "returns 403 when user_id does not match authenticated user" do
    user = create_user("analytics-spend-forbid-a")
    other = create_user("analytics-spend-forbid-b")
    headers = user.create_new_auth_token

    get spending_api_v1_user_analytics_path(
      other,
      params: {
        currency: "PLN",
        start_date: "01-04-2026",
        end_date: "02-04-2026"
      }
    ),
      headers: headers,
      as: :json

    assert_response :forbidden
  end

  test "returns 422 for invalid date range" do
    user = create_user("analytics-spend-invalid")
    headers = user.create_new_auth_token

    get spending_api_v1_user_analytics_path(
      user,
      params: {
        currency: "PLN",
        start_date: "05-04-2026",
        end_date: "01-04-2026"
      }
    ),
      headers: headers,
      as: :json

    assert_response :unprocessable_entity
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
