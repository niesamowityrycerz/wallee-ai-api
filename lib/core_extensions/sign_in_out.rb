# frozen_string_literal: true

# Override Devise's bypass_sign_in to avoid writing to the session.
# Required for API-only apps (config.api_only = true) where sessions are disabled.
# See: https://github.com/lynndylanhurley/devise_token_auth/issues/1616
module CoreExtensions
  module SignInOut
    def bypass_sign_in(resource, scope: nil)
      scope ||= Devise::Mapping.find_scope!(resource)
      expire_data_after_sign_in!
      warden.set_user(resource, { store: false }.merge!(scope: scope))
    end
  end
end
