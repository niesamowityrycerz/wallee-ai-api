# frozen_string_literal: true

module SolidQueueLoggable
  def logger
    ActiveJob::Base.logger
  end
end
