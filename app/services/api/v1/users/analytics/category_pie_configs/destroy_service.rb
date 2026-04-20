# frozen_string_literal: true

module Api
  module V1
    module Users
      module Analytics
        module CategoryPieConfigs
          class DestroyService
            def initialize(user:, id:)
              @user = user
              @id = id
            end

            def call
              config = user.category_pie_configs.find_by(id: id)
              return { success: false, error: "Config not found" } unless config

              config.destroy!
              { success: true }
            end

            private

            attr_reader :user, :id
          end
        end
      end
    end
  end
end
