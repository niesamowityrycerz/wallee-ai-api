# frozen_string_literal: true
require "uploadcare"

Uploadcare.config.public_key = Rails.application.credentials.dig(:uploadcare, :public_key)
Uploadcare.config.secret_key = Rails.application.credentials.dig(:uploadcare, :secret_key)
