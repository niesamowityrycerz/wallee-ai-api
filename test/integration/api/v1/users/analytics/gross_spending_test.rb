# frozen_string_literal: true

require "test_helper"

class Api::V1::Users::Analytics::GrossSpendingTest < ActionDispatch::IntegrationTest
  test "returns 403 when show_vat_details is false" do
    user = create_user("analytics-gross-forbid")
    headers = user.create_new_auth_token

    get gross_spending_api_v1_user_analytics_path(
      user,
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

  test "returns daily net, vat, gross and fills gaps with zero when show_vat_details is true" do
    user = create_user("analytics-gross")
    user.user_setting.update!(show_vat_details: true)
    headers = user.create_new_auth_token
    d0 = Date.new(2026, 4, 1)
    d2 = Date.new(2026, 4, 3)
    tx_a = user.transactions.create!(
      name: "A",
      amount: 123.0,
      total_vat: 23.0,
      currency: "PLN",
      transaction_date: d0,
      status: :ready
    )
    tx_a.vat_components.create!(vat_group: "A", rate_percent: 23.0, vat_amount: 23.0)
    tx_b = user.transactions.create!(
      name: "B",
      amount: 50.0,
      total_vat: 10.0,
      currency: "PLN",
      transaction_date: d2,
      status: :ready
    )
    tx_b.vat_components.create!(vat_group: "B", rate_percent: 20.0, vat_amount: 10.0)

    get gross_spending_api_v1_user_analytics_path(
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
    assert_equal(
      {
        "date" => "2026-04-01",
        "net_total" => 100.0,
        "vat_total" => 23.0,
        "gross_total" => 123.0
      },
      body["points"][0]
    )
    assert_equal(
      {
        "date" => "2026-04-02",
        "net_total" => 0.0,
        "vat_total" => 0.0,
        "gross_total" => 0.0
      },
      body["points"][1]
    )
    assert_equal(
      {
        "date" => "2026-04-03",
        "net_total" => 40.0,
        "vat_total" => 10.0,
        "gross_total" => 50.0
      },
      body["points"][2]
    )
  end

  test "only includes ready transactions with amount and at least one vat line" do
    user = create_user("analytics-gross-scope")
    user.user_setting.update!(show_vat_details: true)
    headers = user.create_new_auth_token
    day = Date.new(2026, 5, 10)
    with_vat = user.transactions.create!(
      name: "with vat",
      amount: 100.0,
      total_vat: 20.0,
      currency: "EUR",
      transaction_date: day,
      status: :ready
    )
    with_vat.vat_components.create!(vat_group: "A", rate_percent: 20.0, vat_amount: 20.0)
    user.transactions.create!(
      name: "no vat lines",
      amount: 50.0,
      total_vat: 10.0,
      currency: "EUR",
      transaction_date: day,
      status: :ready
    )
    user.transactions.create!(
      name: "progress",
      amount: 30.0,
      total_vat: 5.0,
      currency: "EUR",
      transaction_date: day,
      status: :in_progress
    )
    tx_nil = user.transactions.create!(
      name: "no amount",
      amount: nil,
      currency: "EUR",
      transaction_date: day,
      status: :ready
    )
    tx_nil.vat_components.create!(vat_group: "A", rate_percent: 20.0, vat_amount: 5.0)

    get gross_spending_api_v1_user_analytics_path(
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
    p = body["points"].first
    assert_equal 100.0, p["gross_total"]
    assert_equal 20.0, p["vat_total"]
    assert_equal 80.0, p["net_total"]
  end

  test "returns 403 when user_id does not match authenticated user" do
    user = create_user("analytics-gross-forbid-a")
    other = create_user("analytics-gross-forbid-b")
    other.user_setting.update!(show_vat_details: true)
    headers = user.create_new_auth_token

    get gross_spending_api_v1_user_analytics_path(
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
    user = create_user("analytics-gross-invalid")
    user.user_setting.update!(show_vat_details: true)
    headers = user.create_new_auth_token

    get gross_spending_api_v1_user_analytics_path(
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
