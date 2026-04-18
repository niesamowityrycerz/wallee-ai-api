# frozen_string_literal: true

module Api
  module V1
    module Users
      module Transactions
        class TagAssignmentList
          def self.call(transaction)
            new(transaction).call
          end

          def initialize(transaction)
            @transaction = transaction
          end

          def call
            rows = @transaction.transaction_tags.includes(:tag).sort_by { |tt| tt.tag.name.downcase }
            rows.map { |tt| ::Api::V1::Users::Tags::TagSerializer.call(tt.tag).merge(source: tt.source) }
          end
        end
      end
    end
  end
end
