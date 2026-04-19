# frozen_string_literal: true

module Api
  module V1
    module Users
      module Tags
        class IndexService < ServiceBase
          ALLOWED_FILTERS = %w[account_member llm].freeze

          def initialize(user:, params:)
            @user = user
            @params = params
          end

          def call
            account = require_account!(user)
            tags = scope(account).to_a
            return { tags: serialize_plain(tags) } unless include_counts?

            counts = tagged_transaction_counts(account, tags.map(&:id))
            { tags: serialize_with_counts(tags, counts) }
          end

          private

          attr_reader :user, :params

          def include_counts?
            ActiveModel::Type::Boolean.new.cast(params[:include_tagged_transactions_count])
          end

          def serialize_plain(tags)
            tags.map { |tag| TagSerializer.call(tag) }
          end

          def scope(account)
            relation = account.tags.order(Arel.sql("lower(name) ASC"))
            filter = params[:created_by].to_s.presence
            return relation if filter.blank?

            raise ValidationError.new({ created_by: [ "is invalid" ] }) unless ALLOWED_FILTERS.include?(filter)

            relation.where(created_by: filter)
          end

          def tagged_transaction_counts(account, tag_ids)
            return {} if tag_ids.empty?

            TransactionTag
              .joins(transaction_record: :user)
              .where(tag_id: tag_ids, users: { account_id: account.id })
              .group(:tag_id)
              .count
          end

          def serialize_with_counts(tags, counts)
            tags.map do |tag|
              TagSerializer.call(tag).merge(
                tagged_transactions_count: counts.fetch(tag.id, 0)
              )
            end
          end
        end
      end
    end
  end
end
