# frozen_string_literal: true

require "test_helper"

class Api::V1::Users::Analytics::SpendingByTagTest < ActionDispatch::IntegrationTest
  test "returns segments sorted by total desc and untagged bucket" do
    user = create_user("analytics-by-tag")
    account = user.reload.account
    suffix = SecureRandom.hex(4)
    groceries = account.tags.create!(name: "Groceries #{suffix}", created_by: :account_member)
    transport = account.tags.create!(name: "Transport #{suffix}", created_by: :account_member)
    headers = user.create_new_auth_token
    day = Date.new(2026, 4, 5)

    tx_split = user.transactions.create!(
      name: "Split",
      amount: 100.0,
      currency: "PLN",
      transaction_date: day,
      status: :ready
    )
    tx_split.transaction_tags.create!(tag: groceries)
    tx_split.transaction_tags.create!(tag: transport)

    tx_g = user.transactions.create!(
      name: "G only",
      amount: 60.0,
      currency: "PLN",
      transaction_date: day,
      status: :ready
    )
    tx_g.transaction_tags.create!(tag: groceries)

    user.transactions.create!(
      name: "No tags",
      amount: 40.0,
      currency: "PLN",
      transaction_date: day,
      status: :ready
    )

    get spending_by_tag_api_v1_user_analytics_path(
      user,
      params: {
        currency: "PLN",
        start_date: "05-04-2026",
        end_date: "05-04-2026"
      }
    ),
      headers: headers,
      as: :json

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "PLN", body["currency"]
    assert_equal "2026-04-05", body["start_date"]
    assert_equal "2026-04-05", body["end_date"]
    assert_equal 40.0, body["untagged_total"]
    assert_equal 1, body["untagged_transaction_count"]

    segs = body["segments"]
    assert_equal 2, segs.size
    g = segs.find { |s| s["tag_id"] == groceries.id }
    t = segs.find { |s| s["tag_id"] == transport.id }
    assert_equal groceries.name, g["tag_name"]
    assert_equal 110.0, g["total"]
    assert_equal 2, g["transaction_count"]
    assert_equal transport.name, t["tag_name"]
    assert_equal 50.0, t["total"]
    assert_equal 1, t["transaction_count"]
    assert segs.first["total"] >= segs.last["total"]
  end

  test "excludes in_progress like spending summary" do
    user = create_user("analytics-by-tag-status")
    account = user.reload.account
    tag = account.tags.create!(name: "One #{SecureRandom.hex(4)}", created_by: :account_member)
    headers = user.create_new_auth_token
    day = Date.new(2026, 6, 1)

    tx = user.transactions.create!(
      name: "X",
      amount: 99.0,
      currency: "EUR",
      transaction_date: day,
      status: :in_progress
    )
    tx.transaction_tags.create!(tag: tag)

    get spending_by_tag_api_v1_user_analytics_path(
      user,
      params: {
        currency: "EUR",
        start_date: "01-06-2026",
        end_date: "01-06-2026"
      }
    ),
      headers: headers,
      as: :json

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal [], body["segments"]
    assert_equal 0.0, body["untagged_total"]
    assert_equal 0, body["untagged_transaction_count"]
  end

  test "returns 403 when user_id does not match authenticated user" do
    user = create_user("analytics-by-tag-forbid-a")
    other = create_user("analytics-by-tag-forbid-b")
    headers = user.create_new_auth_token

    get spending_by_tag_api_v1_user_analytics_path(
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

  private

  def create_user(prefix)
    User.create!(
      email: "#{prefix}-#{SecureRandom.hex(4)}@example.com",
      password: "password",
      password_confirmation: "password"
    )
  end
end
