# frozen_string_literal: true

require "test_helper"

class Api::V1::Users::Tags::TransactionsTest < ActionDispatch::IntegrationTest
  test "returns only transactions with tag and matching filters" do
    user = create_user("tag-tx-list")
    account = user.reload.account
    tag = account.tags.find_by!(name: "Groceries")
    other = account.tags.find_by!(name: "Pets")
    day = Date.new(2026, 4, 10)
    tx_tagged = user.transactions.create!(
      name: "With tag",
      amount: 1.0,
      currency: "USD",
      transaction_date: day,
      status: :ready
    )
    tx_tagged.transaction_tags.create!(tag: tag, source: :user)
    tx_other_tag = user.transactions.create!(
      name: "Other tag",
      amount: 2.0,
      currency: "USD",
      transaction_date: day,
      status: :ready
    )
    tx_other_tag.transaction_tags.create!(tag: other, source: :user)
    tx_no_tag = user.transactions.create!(
      name: "No tag",
      amount: 3.0,
      currency: "USD",
      transaction_date: day,
      status: :ready
    )
    headers = user.create_new_auth_token
    q = { currency: "USD", start_date: "10-04-2026", end_date: "10-04-2026" }

    get transactions_api_v1_user_tag_path(user, tag, params: q), headers: headers, as: :json

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal tag.id, body["id"]
    assert_equal "Groceries", body["name"]
    assert_equal tag.created_at.as_json, body["created_at"]
    ids = body["transactions"].map { |t| t["id"] }
    assert_equal [ tx_tagged.id ], ids
  end

  test "without query params returns all transactions with tag" do
    user = create_user("tag-tx-all")
    account = user.reload.account
    tag = account.tags.find_by!(name: "Groceries")
    day1 = Date.new(2026, 4, 10)
    day2 = Date.new(2026, 5, 1)
    tx1 = user.transactions.create!(
      name: "A", amount: 1.0, currency: "USD", transaction_date: day1, status: :ready
    )
    tx1.transaction_tags.create!(tag: tag, source: :user)
    tx2 = user.transactions.create!(
      name: "B", amount: 2.0, currency: "PLN", transaction_date: day2, status: :ready
    )
    tx2.transaction_tags.create!(tag: tag, source: :user)
    headers = user.create_new_auth_token

    get transactions_api_v1_user_tag_path(user, tag), headers: headers, as: :json

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal tag.created_at.as_json, body["created_at"]
    ids = body["transactions"].map { |t| t["id"] }.sort
    assert_equal [ tx1.id, tx2.id ].sort, ids
  end

  test "returns 422 when only start_date is passed" do
    user = create_user("tag-tx-partial-date")
    tag = user.reload.account.tags.find_by!(name: "Groceries")
    headers = user.create_new_auth_token

    get transactions_api_v1_user_tag_path(user, tag, params: { start_date: "01-01-2026" }),
      headers: headers,
      as: :json

    assert_response :unprocessable_entity
  end

  test "returns 404 when tag is not on account" do
    user = create_user("tag-tx-404")
    user.reload.account
    foreign = Tag.where.not(account_id: user.account_id).first || Tag.create!(
      account: Account.create!,
      name: "Foreign-only-#{SecureRandom.hex(4)}",
      created_by: :account_member
    )
    headers = user.create_new_auth_token
    q = { currency: "USD", start_date: "01-01-2026", end_date: "31-12-2026" }

    get transactions_api_v1_user_tag_path(user, foreign, params: q), headers: headers, as: :json

    assert_response :not_found
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
