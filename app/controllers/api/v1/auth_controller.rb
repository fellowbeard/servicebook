module Api
  module V1
    class AuthController < ApplicationController
      def login
        user = User.find_by(email: params[:email])

        if user&.authenticate(params[:password])
          token = JwtService.encode(user_id: user.id)
          render json: {
            token: token,
            user: user.as_json(
              only: [:id, :account_id, :role, :first_name, :last_name, :email]
            )
          }
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end
    end
  end
end