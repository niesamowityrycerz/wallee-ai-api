# frozen_string_literal: true

require "test_helper"

class Api::V1::Users::TagsTest < ActionDispatch::IntegrationTest
  test "lists tags for the user account" do
    user = create_user("tags-index")
    headers = user.create_new_auth_token

    get api_v1_user_tags_path(user), headers: headers, as: :json

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 15, body["tags"].size
    assert body["tags"].first.key?("created_by")
    assert body["tags"].none? { |t| t.key?("tagged_transactions_count") }
  end

  test "include_tagged_transactions_count adds usage field to each tag" do
    user = create_user("tags-index-counts")
    headers = user.create_new_auth_token

    get api_v1_user_tags_path(user, include_tagged_transactions_count: true),
      headers: headers,
      as: :json

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 15, body["tags"].size
    assert body["tags"].all? { |t| t.key?("tagged_transactions_count") }
    assert body["tags"].all? { |t| t["tagged_transactions_count"].is_a?(Integer) }
  end

  test "tagged_transactions_count sums across all users on the account" do
    user1 = create_user("tags-count-a")
    account = user1.reload.account
    user2 = User.create!(
      email: "tags-count-b-#{SecureRandom.hex(4)}@example.com",
      password: "password",
      password_confirmation: "password",
      account: account
    )
    tag = account.tags.find_by!(name: "Groceries")
    day = Date.current
    tx1 = user1.transactions.create!(
      name: "U1", amount: 1.0, currency: "USD", transaction_date: day, status: :ready
    )
    tx1.transaction_tags.create!(tag: tag, source: :user)
    tx2 = user2.transactions.create!(
      name: "U2", amount: 2.0, currency: "USD", transaction_date: day, status: :ready
    )
    tx2.transaction_tags.create!(tag: tag, source: :llm)
    headers = user1.create_new_auth_token

    get api_v1_user_tags_path(user1, include_tagged_transactions_count: true),
      headers: headers,
      as: :json

    assert_response :success
    groceries = JSON.parse(response.body)["tags"].find { |t| t["name"] == "Groceries" }
    assert_equal 2, groceries["tagged_transactions_count"]
  end

  test "include_tagged_transactions_count false omits usage field" do
    user = create_user("tags-no-count")
    headers = user.create_new_auth_token

    get api_v1_user_tags_path(user, include_tagged_transactions_count: false),
      headers: headers,
      as: :json

    assert_response :success
    assert JSON.parse(response.body)["tags"].none? { |t| t.key?("tagged_transactions_count") }
  end

  test "filters tags by created_by" do
    user = create_user("tags-filter")
    account = user.reload.account
    account.tags.where(created_by: :account_member).delete_all
    account.tags.create!(name: "Only LLM", created_by: :llm)
    headers = user.create_new_auth_token

    get api_v1_user_tags_path(user, created_by: "llm"), headers: headers, as: :json

    assert_response :success
    names = JSON.parse(response.body)["tags"].pluck("name")
    assert_equal [ "Only LLM" ], names
  end

  test "creates a tag" do
    user = create_user("tags-create")
    headers = user.create_new_auth_token

    assert_difference -> { user.reload.account.tags.count }, +1 do
      post api_v1_user_tags_path(user), params: { name: "My label" }, headers: headers, as: :json
    end

    assert_response :created
    data = JSON.parse(response.body)
    assert_equal "My label", data["name"]
    assert_equal "account_member", data["created_by"]
  end

  test "returns 422 when name duplicates existing tag case-insensitively" do
    user = create_user("tags-dup")
    headers = user.create_new_auth_token

    post api_v1_user_tags_path(user), params: { name: "GROCERIES" }, headers: headers, as: :json

    assert_response :unprocessable_entity
    assert JSON.parse(response.body)["errors"].key?("name")
  end

  test "updates a tag" do
    user = create_user("tags-update")
    tag = user.reload.account.tags.find_by(name: "Groceries")
    headers = user.create_new_auth_token

    patch api_v1_user_tag_path(user, tag), params: { name: "Groceries updated" }, headers: headers, as: :json

    assert_response :success
    assert_equal "Groceries updated", JSON.parse(response.body)["name"]
  end

  test "destroys a tag" do
    user = create_user("tags-destroy")
    tag = user.reload.account.tags.find_by(name: "Pets")
    headers = user.create_new_auth_token

    assert_difference -> { user.reload.account.tags.count }, -1 do
      delete api_v1_user_tag_path(user, tag), headers: headers, as: :json
    end

    assert_response :no_content
  end

  test "returns forbidden when user_id does not match" do
    user = create_user("tags-self")
    other = create_user("tags-other")
    headers = user.create_new_auth_token

    get api_v1_user_tags_path(other), headers: headers, as: :json

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
