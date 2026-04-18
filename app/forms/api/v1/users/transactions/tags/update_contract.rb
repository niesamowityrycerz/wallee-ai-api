# frozen_string_literal: true

module Api
  module V1
    module Users
      module Transactions
        module Tags
          class UpdateContract < Dry::Validation::Contract
            params do
              optional(:add_tag_ids).maybe(:array)
              optional(:remove_tag_ids).maybe(:array)
            end

            rule(:add_tag_ids) do
              next unless key? && value
              key.failure("must be an array") unless value.is_a?(Array)
              next if value.is_a?(Array) && value.all? { |i| tag_id_element?(i) }

              key.failure("must contain only positive integers")
            end

            rule(:remove_tag_ids) do
              next unless key? && value
              key.failure("must be an array") unless value.is_a?(Array)
              next if value.is_a?(Array) && value.all? { |i| tag_id_element?(i) }

              key.failure("must contain only positive integers")
            end

            rule(:add_tag_ids, :remove_tag_ids) do
              add = Array(values[:add_tag_ids]).map(&:to_i).reject(&:zero?)
              rem = Array(values[:remove_tag_ids]).map(&:to_i).reject(&:zero?)
              base.failure("add_tag_ids and remove_tag_ids must not overlap") if (add & rem).any?
            end

            def tag_id_element?(value)
              return false if value.nil?

              int =
                case value
                when Integer then value
                when String then Integer(value, 10)
                else
                  return false
                end
              int.positive?
            rescue ArgumentError, TypeError
              false
            end
          end
        end
      end
    end
  end
end
