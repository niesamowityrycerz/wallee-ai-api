RubyLLM.configure do |config|
  config.openai_api_key = Rails.application.credentials.fetch(:openai).all_purpose_key
  config.default_model = "gpt-5.4-mini"

  # Use the new association-based acts_as API (recommended)
  config.use_new_acts_as = true
end
