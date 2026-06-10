module Api
  module V1
    class BaseController < ActionController::API
      private

      def current_user
        @current_user ||= User.find_by(id: request.headers["X-User-Id"])
      end

      def require_current_user
        return if current_user

        render json: { error: "You must be logged in." }, status: :unauthorized
      end

      def require_write_access
        return if current_user.can_write?

        render json: { error: "Read-only users cannot make changes." }, status: :forbidden
      end
    end
  end
end
