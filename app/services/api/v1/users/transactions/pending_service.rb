# frozen_string_literal: true

module Api
  module V1
    module Users
      module Transactions
        class PendingService
          attr_reader :user

          def initialize(user:)
            @user = user
          end

          def call
            { pending_transactions: user.transactions.in_progress.pluck(:id) }
          end
        end
      end
    end
  end
end
