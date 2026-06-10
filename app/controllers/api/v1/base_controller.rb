module Api
  module V1
    class BaseController < ActionController::API
      def require_write_access
        return unless current_user.read_only?

        render json: { error: "Read-only users cannot make changes." }, status: :forbidden
      end
    end
  end
end
