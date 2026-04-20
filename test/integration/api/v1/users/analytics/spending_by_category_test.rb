# frozen_string_literal: true

require "test_helper"

class Api::V1::Users::Analytics::SpendingByCategoryTest < ActionDispatch::IntegrationTest
  test "returns segment totals from position total_price by category" do
    travel_to Date.new(2026, 4, 10) do
      user = create_user("analytics-by-cat")
      headers = user.create_new_auth_token
      day = Date.new(2026, 4, 5)

      tx = user.transactions.create!(
        name: "Shop",
        amount: 100.0,
        currency: "PLN",
        transaction_date: day,
        status: :ready
      )
      tx.positions.create!(name: "Milk", category: "dairy", quantity: 1, unit_price: 30, total_price: 30)
      tx.positions.create!(name: "Apples", category: "fruits_and_vegetables", quantity: 1, unit_price: 70, total_price: 70)

      cfg = user.category_pie_configs.create!(
        name: "Groceries",
        categories: %w[dairy fruits_and_vegetables]
      )

      get spending_by_category_api_v1_user_analytics_path(
        user,
        params: {
          currency: "PLN",
          start_date: "05-04-2026",
          end_date: "05-04-2026",
          category_pie_config_id: cfg.id
        }
      ),
        headers: headers,
        as: :json

      assert_response :success
      body = JSON.parse(response.body)
      assert_equal "PLN", body["currency"]
      assert_equal cfg.id, body["category_pie_config_id"]
      segs = body["segments"]
      assert_equal 2, segs.size
      dairy = segs.find { |s| s["category"] == "dairy" }
      fv = segs.find { |s| s["category"] == "fruits_and_vegetables" }
      assert_equal 70.0, fv["total"]
      assert_equal 30.0, dairy["total"]
      assert_equal 1, fv["transaction_count"]
      assert_equal 1, dairy["transaction_count"]
      assert segs.first["total"] >= segs.last["total"]
    end
  end

  test "returns 404 when config belongs to another user" do
    travel_to Date.new(2026, 4, 10) do
      user = create_user("analytics-cat-a")
      other = create_user("analytics-cat-b")
      headers = user.create_new_auth_token
      cfg = other.category_pie_configs.create!(name: "X", categories: %w[dairy])

      get spending_by_category_api_v1_user_analytics_path(
        user,
        params: {
          currency: "PLN",
          start_date: "01-04-2026",
          end_date: "05-04-2026",
          category_pie_config_id: cfg.id
        }
      ),
        headers: headers,
        as: :json

      assert_response :not_found
    end
  end

  test "returns 403 when user_id does not match authenticated user" do
    user = create_user("analytics-cat-forbid-a")
    other = create_user("analytics-cat-forbid-b")
    cfg = user.category_pie_configs.create!(name: "C", categories: %w[dairy])
    headers = user.create_new_auth_token

    get spending_by_category_api_v1_user_analytics_path(
      other,
      params: {
        currency: "PLN",
        start_date: "01-04-2026",
        end_date: "02-04-2026",
        category_pie_config_id: cfg.id
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
