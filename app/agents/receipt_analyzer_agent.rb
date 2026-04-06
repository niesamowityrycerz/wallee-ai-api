# frozen_string_literal: true

class ReceiptAnalyzerAgent < RubyLLM::Agent
  model "gpt-5-mini"
  instructions categories: -> { Transaction::Position::CATEGORIES }
  schema ReceiptAnalysisSchema
  temperature 0.1
end
