# frozen_string_literal: true

class TransactionTaggingSchema < RubyLLM::Schema
  array :existing_tag_ids,
        description: "Primary keys from the tag catalog that fit. Use [] when none apply." do
    number description: "Tag id from the catalog JSON"
  end

  array :new_tag_names,
        description: "At most 3 new general English labels when no catalog tag fits. Use [] when none." do
    string description: "Short, reusable tag name"
  end
end
