# frozen_string_literal: true

module Api
  module V1
    module Users
      module Tags
        class DestroyService < ServiceBase
          def initialize(user:, id:)
            @user = user
            @id = id
          end

          def call
            account = require_account!(user)
            tag = account.tags.find_by(id: id)
            return { success: false, error: "Tag not found" } unless tag

            tag.destroy!
            { success: true }
          end

          private

          attr_reader :user, :id
        end
      end
    end
  end
end
