# frozen_string_literal: true

module Api
  module V1
    module Users
      module Tags
        class CreateService < ServiceBase
          def initialize(user:, params:)
            @user = user
            @params = params
          end

          def call
            account = require_account!(user)
            validated = validate(contract, params)
            name = validated[:name].strip
            raise_duplicate_name! if name_taken?(account, name)

            tag = account.tags.create!(name: name, created_by: :account_member)
            { success: true, data: TagSerializer.call(tag) }
          end

          private

          attr_reader :user, :params

          def contract
            @contract ||= ::Api::V1::Users::Tags::CreateContract.new
          end
        end
      end
    end
  end
end
