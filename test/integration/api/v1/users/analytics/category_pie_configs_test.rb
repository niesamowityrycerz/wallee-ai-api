# frozen_string_literal: true

require "test_helper"

class Api::V1::Users::Analytics::CategoryPieConfigsTest < ActionDispatch::IntegrationTest
  test "index lists configs for user" do
    user = create_user("cpc-index")
    user.category_pie_configs.create!(name: "Alpha", categories: %w[dairy])
    headers = user.create_new_auth_token

    get api_v1_user_analytics_category_pie_configs_path(user), headers: headers, as: :json

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 1, body["category_pie_configs"].size
    assert_equal "Alpha", body["category_pie_configs"].first["name"]
  end

  test "create returns 422 when fourth config" do
    user = create_user("cpc-max")
    3.times { |i| user.category_pie_configs.create!(name: "C#{i}", categories: %w[dairy]) }
    headers = user.create_new_auth_token

    post api_v1_user_analytics_category_pie_configs_path(user),
         params: { name: "Too many", categories: %w[snacks_and_sweets] },
         headers: headers,
         as: :json

    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert body["errors"]["base"].present?
  end

  test "create returns 422 when name duplicate" do
    user = create_user("cpc-dup")
    user.category_pie_configs.create!(name: "Same", categories: %w[dairy])
    headers = user.create_new_auth_token

    post api_v1_user_analytics_category_pie_configs_path(user),
         params: { name: "same", categories: %w[groceries] },
         headers: headers,
         as: :json

    assert_response :unprocessable_entity
    assert JSON.parse(response.body)["errors"]["name"].present?
  end

  test "update and destroy" do
    user = create_user("cpc-mut")
    cfg = user.category_pie_configs.create!(name: "A", categories: %w[dairy])
    headers = user.create_new_auth_token

    patch api_v1_user_analytics_category_pie_config_path(user, cfg),
          params: { name: "Renamed" },
          headers: headers,
          as: :json

    assert_response :success
    assert_equal "Renamed", JSON.parse(response.body)["name"]

    delete api_v1_user_analytics_category_pie_config_path(user, cfg),
           headers: headers,
           as: :json

    assert_response :no_content
    assert_equal 0, user.category_pie_configs.count
  end

  test "returns 403 when user mismatch" do
    user = create_user("cpc-forbid-a")
    other = create_user("cpc-forbid-b")
    headers = user.create_new_auth_token

    get api_v1_user_analytics_category_pie_configs_path(other), headers: headers, as: :json

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
