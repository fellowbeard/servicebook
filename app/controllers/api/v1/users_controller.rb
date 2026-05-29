module Api
  module V1
    class UsersController < BaseController
      before_action :set_user, only: %i[show update destroy dashboard]

      def index
        users = User.all
        render json: users
      end

      def show
        render json: @user
      end

      # GET /api/v1/users/:id/dashboard
      def dashboard
        # clients associated via services owned by this user
        clients_scope = Client.joins(:services).where(services: { user_id: @user.id }).distinct
        appointments_scope = Appointment.joins(:services).where(services: { user_id: @user.id }).distinct

        render json: {
          user: @user.as_json(only: [:id, :first_name, :last_name, :email]),
          clients_count: clients_scope.count,
          appointments_count: appointments_scope.count,
          recent_clients: clients_scope.order(created_at: :desc).limit(5).as_json(only: [:id, :first_name, :last_name, :email, :phone]),
          recent_appointments: appointments_scope.order(scheduled_at: :desc).limit(5).as_json(only: [:id, :scheduled_at, :client_id])
        }
      end

      def create
        user = User.new(user_params)
        if user.save
          render json: user, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @user.update(user_params)
          render json: @user
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @user.destroy
        head :no_content
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params.require(:user).permit(:first_name, :last_name, :email)
      end
    end
  end
end
