# frozen_string_literal: true

module Api
  module V1
    module Users
      module Transactions
        class DestroyService
          attr_reader :user, :id, :transaction

          def initialize(user:, id:)
            @user = user
            @id = id
            @transaction = nil
          end

          def call
            @transaction = user.transactions.find_by(id: id)
            return { success: false, error: "Transaction not found" } unless transaction

            transaction.destroy!
            { success: true }
          end
        end
      end
    end
  end
end
