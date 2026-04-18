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
            { tags: serialize(scope(account)) }
          end

          private

          attr_reader :user, :params

          def scope(account)
            relation = account.tags.order(Arel.sql("lower(name) ASC"))
            filter = params[:created_by].to_s.presence
            return relation if filter.blank?

            raise ValidationError.new({ created_by: [ "is invalid" ] }) unless ALLOWED_FILTERS.include?(filter)

            relation.where(created_by: filter)
          end

          def serialize(tags)
            tags.map { |tag| TagSerializer.call(tag) }
          end
        end
      end
    end
  end
end
