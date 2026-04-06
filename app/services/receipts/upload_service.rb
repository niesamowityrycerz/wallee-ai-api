# frozen_string_literal: true

module Receipts
  class UploadService
    attr_reader :file

    def initialize(file:)
      @file = file
    end

    def call
      uploaded_file = Uploadcare::Uploader.upload(file, store: "auto")
      { success: true, url: "https://ucarecdn.com/#{uploaded_file.uuid}/-/format/jpeg/" }
    rescue Uploadcare::Exception::RequestError, StandardError => e
      { success: false, error: e.message }
    end
  end
end
