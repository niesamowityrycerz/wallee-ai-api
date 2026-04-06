# frozen_string_literal: true

Rails.application.config.after_initialize do
  ActiveJob::Base.logger = ActiveSupport::BroadcastLogger.new(
    Logger.new($stdout),
    Logger.new(Rails.root.join("log/solid_queue.log"))
  )
end
