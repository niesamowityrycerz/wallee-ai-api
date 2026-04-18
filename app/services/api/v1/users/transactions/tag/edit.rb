# frozen_string_literal: true

module Api
  module V1
    module Users
      module Transactions
        module Tag
          class Edit < BaseService
            def initialize(transaction:, add_tag_ids:, remove_tag_ids:)
              @transaction = transaction
              @add_tag_ids = Array(add_tag_ids).map(&:to_i).reject(&:zero?).uniq
              @remove_tag_ids = Array(remove_tag_ids).map(&:to_i).reject(&:zero?).uniq
            end

            def call
              return if add_tag_ids.empty? && remove_tag_ids.empty?

              assert_no_overlap!
              account = require_account!
              assert_tags_on_account!(account)

              ActiveRecord::Base.transaction do
                remove_assignments!
                add_tag_ids.each { |tag_id| upsert_user_assignment!(tag_id) }
              end
            end

            private

            attr_reader :transaction, :add_tag_ids, :remove_tag_ids

            def assert_no_overlap!
              return if (add_tag_ids & remove_tag_ids).empty?

              raise ValidationError.new({ tag_ids: [ "add_tag_ids and remove_tag_ids must not overlap" ] })
            end

            def require_account!
              transaction.user.account || raise(ValidationError.new({ account: [ "is required" ] }))
            end

            def assert_tags_on_account!(account)
              needed = (add_tag_ids + remove_tag_ids).uniq
              return if needed.empty?

              allowed = account.tags.where(id: needed).pluck(:id)
              missing = needed - allowed
              return if missing.empty?

              raise ValidationError.new({ tag_ids: [ "unknown or not allowed: #{missing.sort.join(", ")}" ] })
            end

            def remove_assignments!
              transaction.transaction_tags.where(tag_id: remove_tag_ids).delete_all
            end

            def upsert_user_assignment!(tag_id)
              row = transaction.transaction_tags.find_by(tag_id: tag_id)
              if row
                row.update!(source: :user) unless row.user?
              else
                transaction.transaction_tags.create!(tag_id: tag_id, source: :user)
              end
            end
          end
        end
      end
    end
  end
end
