# frozen_string_literal: true

module Api
  module V1
    module Users
      module Analytics
        module CategoryPieConfigSerializer
          module_function

          def call(config)
            {
              id: config.id,
              name: config.name,
              categories: config.categories,
              created_at: config.created_at,
              updated_at: config.updated_at
            }
          end
        end
      end
    end
  end
end
