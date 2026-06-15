module Api
  module V1
    class BaseController < ActionController::API
      before_action :require_current_user

      private

      def current_user
        return @current_user if defined?(@current_user)

        header = request.headers["Authorization"]
        token = header&.split(" ")&.last
        payload = JwtService.decode(token)

        @current_user = User.find_by(id: payload["user_id"]) if payload
      end

      def require_current_user
        return if current_user

        render json: { error: "Unauthorized" }, status: :unauthorized
      end

      def current_account
        current_user.account
      end

      def require_write_access
        return if current_user.can_write?

        render json: { error: "Read-only users cannot make changes." }, status: :forbidden
      end

      def require_owner
        return if current_user.owner?

        render json: { error: "Only account owners can do that." }, status: :forbidden
      end
    end
  end
end
