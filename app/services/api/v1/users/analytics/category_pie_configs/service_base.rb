# frozen_string_literal: true

module Api
  module V1
    module Users
      module Analytics
        module CategoryPieConfigs
          class ServiceBase < BaseService
            private

            def name_taken?(user, name, exclude_id: nil)
              scope = ::CategoryPieConfig.where(user_id: user.id).where("lower(name) = ?", name.downcase)
              scope = scope.where.not(id: exclude_id) if exclude_id
              scope.exists?
            end

            def raise_duplicate_name!
              raise ValidationError.new({ name: [ "has already been taken" ] })
            end

            def raise_max_configs!
              raise ValidationError.new({ base: [ "maximum of 3 category pie configs reached" ] })
            end
          end
        end
      end
    end
  end
end
