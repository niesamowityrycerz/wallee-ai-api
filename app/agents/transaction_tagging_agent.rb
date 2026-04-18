# frozen_string_literal: true

class TransactionTaggingAgent < RubyLLM::Agent
  INSTRUCTIONS_PATH = Rails.root.join("app/prompts/transaction_tagging_agent/instructions.txt")

  model "gpt-5-mini"
  instructions File.read(INSTRUCTIONS_PATH)
  schema TransactionTaggingSchema
  temperature 0.1
end
