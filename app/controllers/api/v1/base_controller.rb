module Api
  module V1
    class BaseController < ActionController::API
      before_action :require_current_user

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

      def current_account
        current_user.account
      end

      def require_owner
        return if current_user.owner?

        render json: { error: "Only account owners can do that." }, status: :forbidden
      end
    end
  end
end
