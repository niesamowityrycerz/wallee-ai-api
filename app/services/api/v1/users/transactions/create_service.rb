# frozen_string_literal: true

module Api
  module V1
    module Users
      module Transactions
        class CreateService
          attr_reader :user, :params, :image

          def initialize(user:, params:, image:)
            @user = user
            @params = params
            @image = image
          end

          def call
            @transaction = user.transactions.build(params)
            return failure(@transaction.errors.full_messages) unless @transaction.valid?

            upload_result = upload_image
            return failure([ upload_result[:error] ]) unless upload_result[:success]

            persist_transaction!(upload_result[:url])
            enqueue_processing!
            success
          rescue ActiveRecord::RecordInvalid => e
            failure(e.record.errors.full_messages)
          end

          private

          def upload_image
            Receipts::UploadService.new(file: image).call
          end

          def persist_transaction!(image_url)
            ActiveRecord::Base.transaction do
              @transaction.save!
              @transaction.images.create!(image_url: image_url)
            end
          end

          def enqueue_processing!
            Transaction::Processing.perform_later(@transaction.id)
          end

          def success
            { success: true, transaction: @transaction }
          end

          def failure(errors)
            { success: false, errors: errors }
          end
        end
      end
    end
  end
end
