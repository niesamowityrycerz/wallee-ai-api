# frozen_string_literal: true

module Api
  module V1
    module Users
      module Analytics
        module CategoryPieConfigs
          class UpdateService < ServiceBase
            def initialize(user:, id:, params:)
              @user = user
              @id = id
              @params = params
            end

            def call
              config = user.category_pie_configs.find_by(id: id)
              return { success: false, error: "Config not found" } unless config

              validated = validate(contract, params)
              attrs = build_attributes(validated)
              raise_duplicate_name! if attrs[:name] && name_taken?(user, attrs[:name], exclude_id: config.id)

              config.update!(attrs)
              { success: true, data: CategoryPieConfigSerializer.call(config) }
            end

            private

            attr_reader :user, :id, :params

            def contract
              @contract ||= ::Api::V1::Users::Analytics::CategoryPieConfigs::UpdateContract.new
            end

            def build_attributes(validated)
              attrs = {}
              attrs[:name] = validated[:name].strip if validated[:name]
              attrs[:categories] = validated[:categories].map(&:to_s).uniq if validated[:categories]
              attrs
            end
          end
        end
      end
    end
  end
end
