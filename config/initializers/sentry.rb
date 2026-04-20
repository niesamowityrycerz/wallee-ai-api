# frozen_string_literal: true

return if Rails.env.development?
return if Rails.env.test?

Sentry.init do |config|
  config.dsn = Rails.application.credentials.sentry.fetch(:dsn)
  config.environment = Rails.env.production? ? "production" : "staging"

  config.breadcrumbs_logger = [ :active_support_logger, :http_logger ]
  config.send_default_pii = Rails.env.production? ? false : true

  config.traces_sample_rate = Rails.application.credentials.sentry.fetch(:traces_sample_rate, 0.0)
  config.profiles_sample_rate = Rails.application.credentials.sentry.fetch(:profiles_sample_rate, 0.0)

  config.before_send_transaction = lambda do |event, _hint|
    name = event.transaction
    next event unless name

    name.include?("/up") ? nil : event
  end
end
