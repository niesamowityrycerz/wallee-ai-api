require "test_helper"

class TransactionProcessingTest < ActiveSupport::TestCase
  test "marks transaction with status based on id parity" do
    transaction = create_transaction
    job = processing_job_class.new

    job.perform(transaction.id)

    expected_status = transaction.id.even? ? "ready" : "failed"

    assert_equal expected_status, transaction.reload.status
  end

  private

  def processing_job_class
    Class.new(Transaction::Processing) do
      private

      def simulate_processing!(_transaction)
      end
    end
  end

  def create_transaction
    user = User.create!(
      email: "processing-#{SecureRandom.hex(4)}@example.com",
      password: "password",
      password_confirmation: "password"
    )

    user.transactions.create!(
      name: "Test",
      amount: 10.0,
      currency: "USD",
      transaction_date: Date.current
    )
  end
end
