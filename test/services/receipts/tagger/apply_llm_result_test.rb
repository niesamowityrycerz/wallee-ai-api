# frozen_string_literal: true

require "test_helper"

module Receipts
  module Tagger
    class ApplyLlmResultTest < ActiveSupport::TestCase
      test "replaces llm tags and keeps user tags" do
        user = User.create!(
          email: "tagger-#{SecureRandom.hex(4)}@example.com",
          password: "password",
          password_confirmation: "password"
        )
        account = user.reload.account
        tags = account.tags.order(:id).to_a

        tx = user.transactions.create!(
          name: "Test",
          store_name: "Store",
          amount: 10.0,
          currency: "USD",
          transaction_date: Date.current
        )
        tx.transaction_tags.create!(tag: tags[0], source: :user)
        tx.transaction_tags.create!(tag: tags[1], source: :llm)

        ApplyLlmResult.new(
          transaction: tx,
          result: {
            "existing_tag_ids" => [ tags[2].id ],
            "new_tag_names" => []
          }
        ).call

        tx.reload
        assert_equal [ tags[0].id ], tx.transaction_tags.where(source: :user).pluck(:tag_id)
        assert_equal [ tags[2].id ], tx.transaction_tags.where(source: :llm).pluck(:tag_id)
      end

      test "creates llm tag for new names" do
        user = User.create!(
          email: "tagger-new-#{SecureRandom.hex(4)}@example.com",
          password: "password",
          password_confirmation: "password"
        )
        account = user.reload.account

        tx = user.transactions.create!(
          name: "Test",
          store_name: "Store",
          amount: 1.0,
          currency: "USD",
          transaction_date: Date.current
        )

        ApplyLlmResult.new(
          transaction: tx,
          result: { "existing_tag_ids" => [], "new_tag_names" => [ "Custom label" ] }
        ).call

        tag = account.tags.where("lower(name) = ?", "custom label").first
        assert_not_nil tag
        assert tag.llm?
        assert_equal [ tag.id ], tx.reload.transaction_tags.where(source: :llm).pluck(:tag_id)
      end
    end
  end
end
