# frozen_string_literal: true

class ReceiptGroupingAgent < RubyLLM::Agent
  model "gpt-4o"
  schema ReceiptGroupingSchema
  temperature 0.1
  instructions <<~PROMPT
    You are a receipt grouping assistant. You will receive a list of image URLs.
    Your task is to examine the images and group them by receipt.

    Rules:
    - Images that show different parts of the same physical receipt (e.g. top and bottom) must be placed in the same group.
    - Each distinct receipt must be its own group.
    - Every provided image URL must appear in exactly one group — do not omit any.
    - Use visual cues to identify matches: same store, same date/time, same transaction total, sequential page numbers, or visual continuity between images.
    - CRITICAL: You must return image URLs exactly as you received them — do not alter, truncate, encode, decode, or reconstruct any URL. Copy each URL verbatim into your response.
  PROMPT
end
