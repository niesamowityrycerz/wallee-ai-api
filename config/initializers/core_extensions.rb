# frozen_string_literal: true

# Load and apply core extension monkey patches (e.g. Devise session bypass for API-only).
Dir[Rails.root.join("lib", "core_extensions", "*.rb")].sort.each { |f| require f }

Devise::Controllers::SignInOut.prepend CoreExtensions::SignInOut
