# frozen_string_literal: true

module Receipts
  module Tagger
    class ApplyLlmResult
      MAX_EXISTING_IDS = 10
      MAX_NEW_NAMES = 3

      def initialize(transaction:, result:)
        @transaction = transaction
        @result = normalize_result(result)
      end

      def call
        return if account.blank?

        apply!(collect_tag_ids.uniq)
      end

      private

      attr_reader :transaction, :result

      def account
        @account ||= transaction.user.account
      end

      def collect_tag_ids
        ids = valid_existing_ids
        append_new_tag_ids(ids)
        ids
      end

      def valid_existing_ids
        raw = raw_existing_ids
        allowed = account.tags.where(id: raw).pluck(:id)
        log_invalid(raw, allowed) if allowed.size < raw.size
        allowed
      end

      def raw_existing_ids
        Array(result["existing_tag_ids"]).map(&:to_i).reject(&:zero?).first(MAX_EXISTING_IDS)
      end

      def log_invalid(raw, allowed)
        Rails.logger.warn(
          "Tagging dropped invalid tag ids for transaction #{transaction.id}: #{(raw - allowed).inspect}"
        )
      end

      def append_new_tag_ids(ids)
        new_names.each do |name|
          tag = find_or_create_llm_tag(name)
          ids << tag.id if tag
        end
      end

      def new_names
        Array(result["new_tag_names"]).map { |n| n.to_s.strip }.reject(&:blank?).first(MAX_NEW_NAMES)
      end

      def find_or_create_llm_tag(name)
        find_by_ci_name(name) || create_llm_tag(name)
      end

      def find_by_ci_name(name)
        account.tags.where("lower(name) = ?", name.downcase).first
      end

      def create_llm_tag(name)
        account.tags.create!(name: name, created_by: :llm)
      rescue ActiveRecord::RecordNotUnique
        find_by_ci_name(name)
      end

      def apply!(tag_ids)
        transaction.transaction_tags.where(source: :llm).delete_all
        tag_ids.each { |tag_id| create_llm_row(tag_id) }
      end

      def create_llm_row(tag_id)
        transaction.transaction_tags.create!(tag_id: tag_id, source: :llm)
      end

      def normalize_result(raw)
        hash =
          case raw
          when Hash then raw
          when String then JSON.parse(raw)
          else {}
          end
        hash.stringify_keys
      rescue JSON::ParserError, TypeError
        {}
      end
    end
  end
end
