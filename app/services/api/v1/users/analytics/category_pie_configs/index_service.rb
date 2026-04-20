# frozen_string_literal: true

module Api
  module V1
    module Users
      module Analytics
        module CategoryPieConfigs
          class IndexService
            def initialize(user:)
              @user = user
            end

            def call
              configs = user.category_pie_configs.order(:name)
              {
                category_pie_configs: configs.map { |c| CategoryPieConfigSerializer.call(c) }
              }
            end

            private

            attr_reader :user
          end
        end
      end
    end
  end
end
