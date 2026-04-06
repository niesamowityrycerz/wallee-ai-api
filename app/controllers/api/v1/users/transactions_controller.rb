# frozen_string_literal: true

module Api
  module V1
    module Users
      class TransactionsController < ApplicationController
        before_action :authorize_user!

        def index
          result = Api::V1::Users::Transactions::IndexService.new(user: current_user).call
          render json: serialize_index(result), status: :ok
        end

        def show
          result = Api::V1::Users::Transactions::ShowService.new(user: current_user, id: params[:id]).call
          return render json: { error: result[:error] }, status: :not_found unless result[:success]

          render json: result[:data], status: :ok
        end

        # not used
        # def create
        #   result = Api::V1::Users::Transactions::CreateService.new(
        #     user: current_user,
        #     params: default_transaction_params,
        #     image: params.require(:receipt)
        #   ).call
 
        #   return render json: { errors: result[:errors] }, status: :unprocessable_entity unless result[:success]
 
        #   render json: create_response(result[:transaction]), status: :created
        # end

        def create_by_hand
          result = Api::V1::Users::Transactions::CreateByHandService.new(
            user: current_user,
            params: create_by_hand_params
          ).call

          render json: serialize_create_by_hand(result[:transaction]), status: :created
        rescue BaseService::ValidationError => e
          render json: { errors: e.errors }, status: :unprocessable_entity
        end

        def mass_create
          result = Api::V1::Users::Transactions::MassCreateService.new(
            user: current_user,
            images: params.require(:images)
          ).call

          return render json: { errors: result[:errors] }, status: :unprocessable_entity unless result[:success]

          head :created
        end

        def summary
          result = Api::V1::Users::Transactions::SummaryService.new(
            user: current_user,
            from_date: params[:from_date],
            to_date: params[:to_date]
          ).call

          render json: result, status: :ok
        end

        def pending
          result = Api::V1::Users::Transactions::PendingService.new(user: current_user).call
          render json: result, status: :ok
        end

        def check_statuses
          result = Api::V1::Users::Transactions::CheckStatusesService.new(
            user: current_user,
            ids: params.require(:ids)
          ).call

          render json: result, status: :ok
        end

        def update
          transaction = current_user.transactions.find_by(id: params[:id])
          return render json: { error: "Transaction not found" }, status: :not_found unless transaction

          result = Api::V1::Users::Transactions::UpdateService.new(
            transaction: transaction,
            params: update_params
          ).call

          render json: result[:data], status: :ok
        rescue BaseService::ValidationError => e
          render json: { errors: e.errors }, status: :unprocessable_entity
        end

        def destroy
          result = Api::V1::Users::Transactions::DestroyService.new(user: current_user, id: params[:id]).call
          return render json: { error: result[:error] }, status: :not_found unless result[:success]

          head :no_content
        end

        private

        def serialize_create_by_hand(transaction)
          {
            id: transaction.id,
            title: transaction.name,
            store_name: transaction.store_name,
            transaction_date: transaction.transaction_date,
            status: transaction.status,
            price: transaction.amount.to_f,
            currency: transaction.currency
          }
        end

        def update_params
          params.permit(:name, :amount, :currency, :transaction_date, :store_name, :store_address, :total_discount)
                .to_h.deep_symbolize_keys
        end

        def create_by_hand_params
          params.permit(
            :title, :store_name, :total_price, :currency, :transaction_date,
            positions: [ :name, :quantity, :price, :category, :total_discount ]
          ).to_h.deep_symbolize_keys
        end

        def authorize_user!
          return if params[:user_id].to_s == current_user.id.to_s

          render json: { error: "Forbidden" }, status: :forbidden
        end

        def serialize_index(result)
          {
            transactions: result[:transactions].map do |t|
              {
                id: t.id,
                status: t.status,
                name: t.name,
                amount: t.amount.to_f,
                currency: t.currency,
                transaction_date: t.transaction_date,
                store_name: t.store_name,
                image_urls: t.image_urls,
                created_at: t.created_at,
                updated_at: t.updated_at
              }
            end
          }
        end

      end
    end
  end
end
