# frozen_string_literal: true

module Api
  module V1
    module Users
      module Transactions
        class CheckStatusesService
          attr_reader :user, :ids

          def initialize(user:, ids:)
            @user = user
            @ids = ids
          end

          def call
            { transactions: serialized_transactions }
          end

          private

          def serialized_transactions
            ordered_transactions.map(&:attributes)
          end

          def ordered_transactions
            records_by_id = user.transactions.where(id: normalized_ids).index_by(&:id)
            normalized_ids.filter_map { |id| records_by_id[id] }
          end

          def normalized_ids
            Array(ids).filter_map { |id| Integer(id, exception: false) }.uniq
          end
        end
      end
    end
  end
end
