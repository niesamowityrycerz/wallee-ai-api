# frozen_string_literal: true

module Api
  module V1
    module Users
      module Transactions
        module Tags
          class CreateService < BaseService
            def initialize(transaction:, params:)
              @transaction = transaction
              @params = params
            end

            def call
              validate_status!
              validated = validate(contract, params)
              name = validated[:name].strip
              account = require_account!

              ActiveRecord::Base.transaction do
                tag = find_or_create_tag!(account, name)
                link_tag_unless_present!(tag)
              end

              { success: true }
            end

            private

            attr_reader :transaction, :params

            def contract
              @contract ||= ::Api::V1::Users::Tags::CreateContract.new
            end

            def validate_status!
              return if transaction.ready?

              raise ValidationError.new({ status: [ "transaction must have status 'ready' to be edited" ] })
            end

            def require_account!
              transaction.user.account || raise(ValidationError.new({ account: [ "is required" ] }))
            end

            def find_or_create_tag!(account, name)
              account.tags.where("lower(name) = ?", name.downcase).first ||
                account.tags.create!(name: name, created_by: :account_member)
            end

            def link_tag_unless_present!(tag)
              return if transaction.transaction_tags.exists?(tag_id: tag.id)

              transaction.transaction_tags.create!(tag: tag, source: :user)
            end
          end
        end
      end
    end
  end
end
