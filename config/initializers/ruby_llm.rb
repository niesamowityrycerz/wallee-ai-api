RubyLLM.configure do |config|
  config.openai_api_key = if Rails.env.test?
    "test-placeholder-key"
  else
    Rails.application.credentials.fetch(:openai).all_purpose_key
  end
  config.default_model = "gpt-5.4-mini"

  # Use the new association-based acts_as API (recommended)
  config.use_new_acts_as = true
end
