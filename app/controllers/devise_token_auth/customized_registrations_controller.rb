# frozen_string_literal: true

module DeviseTokenAuth
  class CustomizedRegistrationsController < DeviseTokenAuth::RegistrationsController
   
    def check_email
      user = User.exists?(email: params[:email])

      if user.present?
        render json: {
          status: "failure",
          body: "emails is taken"
        }, status: 422
      else
        render json: {
          status: "success",
          body: "email is free"
        }, status: 200
      end
    end

    # def sign_up_params
    #   params_for_resource(:sign_up) << :inform_about_features
    #   params.permit(*params_for_resource(:sign_up)).merge(
    #     sign_up_ip: request.headers["X-Forwarded-For"]&.split(",")&.first&.strip || request.remote_ip
    #   )
    # end
  end
end
