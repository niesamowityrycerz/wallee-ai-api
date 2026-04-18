# frozen_string_literal: true

class Transaction::Analysis < ApplicationJob
  queue_as :default

  def perform(transaction_id)
    transaction = Transaction.find(transaction_id)

    logger.info "Analyzing transaction #{transaction_id}"

    result = Receipts::Analyzer::Entrypoint.new(transaction:).call

    if result[:success]
      transaction.update!(status: :ready)
      transaction.reload
      Receipts::Tagger::Entrypoint.new(transaction: transaction).call
    else
      transaction.update!(status: :failed)
    end
  rescue StandardError => e
    logger.error "Transaction analysis failed for #{transaction_id}: #{e.message}"
    Transaction.find_by(id: transaction_id)&.update(status: :failed)
    raise e
  end
end
