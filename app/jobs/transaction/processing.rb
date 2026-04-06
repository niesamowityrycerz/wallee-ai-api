# frozen_string_literal: true

class Transaction::Processing < ApplicationJob
  queue_as :default

  def perform(user_id:, image_urls:)
    Receipts::Grouper::Entrypoint.new(user_id:, image_urls:).call
  rescue StandardError => e
    logger.error "Receipt grouping job failed for user #{user_id}: #{e.message}"
    raise e
  end
end
