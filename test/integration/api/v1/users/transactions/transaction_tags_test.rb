# frozen_string_literal: true

require "test_helper"

class Api::V1::Users::Transactions::TransactionTagsTest < ActionDispatch::IntegrationTest
  test "show includes tags with assignment source and tag fields" do
    user = create_user("tx-tags-show")
    account = user.reload.account
    tx = create_ready_transaction(user)
    tag = account.tags.find_by!(name: "Groceries")
    tx.transaction_tags.create!(tag: tag, source: :llm)
    headers = user.create_new_auth_token

    get api_v1_user_transaction_path(user, tx), headers: headers, as: :json

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 1, body["tags"].size
    assert_equal tag.id, body["tags"].first["id"]
    assert_equal "Groceries", body["tags"].first["name"]
    assert_equal "llm", body["tags"].first["source"]
    assert body["tags"].first.key?("created_by")
  end

  test "create transaction tag by name links tag and returns 201 with empty body" do
    user = create_user("tx-tags-create")
    account = user.reload.account
    tx = create_ready_transaction(user)
    headers = user.create_new_auth_token

    assert_difference -> { Tag.where(account_id: account.id).count }, 1 do
      assert_difference -> { TransactionTag.where(transaction_id: tx.id).count }, 1 do
        post api_v1_user_transaction_tags_path(user, tx),
          params: { name: "Custom label" },
          headers: headers,
          as: :json
      end
    end

    assert_response :created
    assert response.body.blank?
    tag = account.tags.where("lower(name) = ?", "custom label").first!
    assert tx.reload.transaction_tags.exists?(tag_id: tag.id, source: :user)
  end

  test "create transaction tag reuses existing tag by case-insensitive name" do
    user = create_user("tx-tags-create-reuse")
    account = user.reload.account
    existing = account.tags.create!(name: "Coffee", created_by: :account_member)
    tx = create_ready_transaction(user)
    headers = user.create_new_auth_token

    assert_no_difference -> { Tag.where(account_id: account.id).count } do
      assert_difference -> { TransactionTag.where(transaction_id: tx.id).count }, 1 do
        post api_v1_user_transaction_tags_path(user, tx),
          params: { name: "  coffee " },
          headers: headers,
          as: :json
      end
    end

    assert_response :created
    assert_equal existing.id, tx.reload.transaction_tags.find_by!(tag_id: existing.id).tag_id
  end

  test "create transaction tag when already linked returns 201 and does not duplicate link" do
    user = create_user("tx-tags-create-idem")
    account = user.reload.account
    tag = account.tags.find_by!(name: "Groceries")
    tx = create_ready_transaction(user)
    tx.transaction_tags.create!(tag: tag, source: :user)
    headers = user.create_new_auth_token

    assert_no_difference -> { Tag.where(account_id: account.id).count } do
      assert_no_difference -> { TransactionTag.where(transaction_id: tx.id).count } do
        post api_v1_user_transaction_tags_path(user, tx),
          params: { name: "Groceries" },
          headers: headers,
          as: :json
      end
    end

    assert_response :created
    assert response.body.blank?
  end

  test "transaction tags patch removes user tag and flips llm tag to user" do
    user = create_user("tx-tags-patch")
    account = user.reload.account
    tx = create_ready_transaction(user)
    t_groceries = account.tags.find_by!(name: "Groceries")
    t_pets = account.tags.find_by!(name: "Pets")
    tx.transaction_tags.create!(tag: t_groceries, source: :user)
    tx.transaction_tags.create!(tag: t_pets, source: :llm)
    headers = user.create_new_auth_token

    patch api_v1_user_transaction_tags_path(user, tx),
      params: { remove_tag_ids: [ t_groceries.id ], add_tag_ids: [ t_pets.id ] },
      headers: headers,
      as: :json

    assert_response :success
    body = JSON.parse(response.body)
    assert_kind_of Array, body["tags"]
    assert(body["tags"].any? { |t| t["id"] == t_pets.id && t["source"] == "user" })
    tx.reload
    assert_not tx.transaction_tags.exists?(tag_id: t_groceries.id)
    row = tx.transaction_tags.find_by!(tag_id: t_pets.id)
    assert row.user?
  end

  test "transaction tags patch remove_tag_ids drops llm assignment" do
    user = create_user("tx-tags-patch-rm-llm")
    account = user.reload.account
    tx = create_ready_transaction(user)
    tag = account.tags.find_by!(name: "Groceries")
    tx.transaction_tags.create!(tag: tag, source: :llm)
    headers = user.create_new_auth_token

    patch api_v1_user_transaction_tags_path(user, tx),
      params: { remove_tag_ids: [ tag.id ], add_tag_ids: [] },
      headers: headers,
      as: :json

    assert_response :success
    tx.reload
    assert_not tx.transaction_tags.exists?(tag_id: tag.id)
    body = JSON.parse(response.body)
    assert_equal [], body["tags"]
  end

  private

  def create_user(prefix)
    User.create!(
      email: "#{prefix}-#{SecureRandom.hex(4)}@example.com",
      password: "password",
      password_confirmation: "password"
    )
  end

  def create_ready_transaction(user)
    user.transactions.create!(
      name: "Test",
      amount: 10.0,
      currency: "USD",
      transaction_date: Date.current,
      status: :ready
    )
  end
end
