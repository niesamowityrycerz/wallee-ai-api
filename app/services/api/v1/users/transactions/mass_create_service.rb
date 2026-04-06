# frozen_string_literal: true

module Api
  module V1
    module Users
      module Transactions
        class MassCreateService
          attr_reader :user, :images

          def initialize(user:, images:)
            @user = user
            @images = images
          end

          def call
            return failure([ "At least one image is required" ]) if normalized_images.empty?

            upload_result = upload_images
            return failure(upload_result[:errors]) unless upload_result[:success]

            trigger_processing!(upload_result[:urls])
            success
          end

          private

          def normalized_images
            Array.wrap(images).compact
          end

          def upload_images
            errors = []
            urls = normalized_images.filter_map do |image|
              upload_result = Receipts::UploadService.new(file: image).call
              errors << upload_result[:error] unless upload_result[:success]
              upload_result[:url] if upload_result[:success]
            end

            return { success: false, errors: errors } if errors.any?

            { success: true, urls: urls }
          end

          def trigger_processing!(image_urls)
            Transaction::Processing.perform_later(user_id: user.id, image_urls: image_urls)
          end

          def success
            { success: true }
          end

          def failure(errors)
            { success: false, errors: errors }
          end
        end
      end
    end
  end
end
