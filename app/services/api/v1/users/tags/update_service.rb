# frozen_string_literal: true

module Api
  module V1
    module Users
      module Tags
        class UpdateService < ServiceBase
          def initialize(user:, id:, params:)
            @user = user
            @id = id
            @params = params
          end

          def call
            account = require_account!(user)
            tag = account.tags.find_by(id: id)
            return { success: false, error: "Tag not found" } unless tag

            validated = validate(contract, params)
            name = validated[:name].strip
            raise_duplicate_name! if name_taken?(account, name, exclude_id: tag.id)

            tag.update!(name: name)
            { success: true, data: TagSerializer.call(tag) }
          end

          private

          attr_reader :user, :id, :params

          def contract
            @contract ||= ::Api::V1::Users::Tags::UpdateContract.new
          end
        end
      end
    end
  end
end
