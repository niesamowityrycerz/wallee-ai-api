# frozen_string_literal: true

module Api
  module V1
    module Users
      module Tags
        module TagSerializer
          module_function

          def call(tag)
            {
              id: tag.id,
              name: tag.name,
              created_by: tag.created_by,
              created_at: tag.created_at,
              updated_at: tag.updated_at
            }
          end
        end
      end
    end
  end
end
