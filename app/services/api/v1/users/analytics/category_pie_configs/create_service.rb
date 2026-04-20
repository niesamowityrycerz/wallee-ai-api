# frozen_string_literal: true

module Api
  module V1
    module Users
      module Analytics
        module CategoryPieConfigs
          class CreateService < ServiceBase
            def initialize(user:, params:)
              @user = user
              @params = params
            end

            def call
              raise_max_configs! if user.category_pie_configs.count >= ::CategoryPieConfig::MAX_CONFIGS_PER_USER

              validated = validate(contract, params)
              name = validated[:name].strip
              raise_duplicate_name! if name_taken?(user, name)

              categories = validated[:categories].map(&:to_s).uniq
              record = user.category_pie_configs.create!(name: name, categories: categories)
              { data: CategoryPieConfigSerializer.call(record) }
            end

            private

            attr_reader :user, :params

            def contract
              @contract ||= ::Api::V1::Users::Analytics::CategoryPieConfigs::CreateContract.new
            end
          end
        end
      end
    end
  end
end
