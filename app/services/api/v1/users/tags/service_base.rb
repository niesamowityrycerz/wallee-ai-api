# frozen_string_literal: true

module Api
  module V1
    module Users
      module Tags
        class ServiceBase < BaseService
          private

          def require_account!(user)
            user.account || raise(ValidationError.new({ account: [ "is required" ] }))
          end

          def name_taken?(account, name, exclude_id: nil)
            scope = account.tags.where("lower(name) = ?", name.downcase)
            scope = scope.where.not(id: exclude_id) if exclude_id
            scope.exists?
          end

          def raise_duplicate_name!
            raise ValidationError.new({ name: [ "has already been taken" ] })
          end
        end
      end
    end
  end
end
