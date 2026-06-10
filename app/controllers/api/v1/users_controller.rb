module Api
  module V1
    class UsersController < BaseController
      before_action :set_user, only: [:show, :update, :destroy, :dashboard]
      before_action :require_write_access, only: [:create, :update, :destroy]

      def index
        users = User.all
        render json: users
      end

      def show
        render json: @user.as_json(only: [:id, :first_name, :last_name, :email])
      end

      def dashboard
        clients_scope = Client.for_user(@user)
        appointments_scope = Appointment.joins(:services).where(services: { user_id: @user.id }).distinct
        services_scope = @user.services.alphabetical
        account_for_user = @user.account

        render json: {
          user: @user.as_json(only: [:id, :account_id, :role, :first_name, :last_name, :email]),
          appointments_count: appointments_scope.count,
          account: AccountSerializer.new(account_for_user).as_json,
          services: services_scope
            .map { |service| ServiceSerializer.new(service).as_json },

          clients: clients_scope
            .order(:last_name, :first_name)
            .map { |client| ClientSerializer.new(client).as_json },

          recent_clients: clients_scope
            .order(created_at: :desc)
            .limit(5)
            .map { |client| ClientSerializer.new(client).as_json },

          appointments: appointments_scope
            .order(:scheduled_at)
            .map { |appointment| AppointmentSerializer.new(appointment).as_json },

          recent_appointments: appointments_scope
            .order(scheduled_at: :desc)
            .limit(5)
            .map do |appointment|
              {
                id: appointment.id,
                client_id: appointment.client_id,
                scheduled_at: appointment.convert_time
              }
            end
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
