# frozen_string_literal: true

class ReceiptGroupingSchema < RubyLLM::Schema
  array :groups, description: "List of receipt groups. Each group contains all image URLs that belong to the same physical receipt." do
    object do
      array :image_urls, description: "List of image URLs that are part of the same receipt" do
        string description: "A single image URL"
      end
    end
  end
end
