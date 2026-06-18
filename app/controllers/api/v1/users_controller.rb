class Api::V1::UsersController < Api::V1::BaseController
  before_action :set_user, only: [:show, :update, :destroy]
  before_action :require_write_access, only: [:create, :update, :destroy]

  def index
    users = current_account.users
    render json: users
  end

  def show
    render json: user_json(@user)
  end

  def dashboard
    render json: dashboard_json
  end

  def create
    user = current_account.users.new(user_params)

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

  def me
    render json: user_json(current_user)
  end

  private

  def dashboard_json
    {
      user: user_json(current_user),
      appointments_count: appointments_scope.count,
      account: AccountSerializer.new(current_account).as_json,
      services: serialized_services,
      clients: serialized_clients,
      recent_clients: serialized_recent_clients,
      appointments: serialized_appointments,
      recent_appointments: serialized_recent_appointments,
    }
  end

  def clients_scope
    current_account.clients
  end

  def appointments_scope
    current_account.appointments.includes(:client, :services, :resource)
  end

  def services_scope
    current_account.services.alphabetical
  end

  def serialized_services
    services_scope.map { |service| ServiceSerializer.new(service).as_json }
  end

  def serialized_clients
    clients_scope
      .order(:last_name, :first_name)
      .map { |client| ClientSerializer.new(client).as_json }
  end

  def serialized_recent_clients
    clients_scope
      .order(created_at: :desc)
      .limit(5)
      .map { |client| ClientSerializer.new(client).as_json }
  end

  def serialized_appointments
    appointments_scope
      .order(:scheduled_at)
      .map { |appointment| AppointmentSerializer.new(appointment).as_json }
  end

  def serialized_recent_appointments
    appointments_scope
      .order(scheduled_at: :desc)
      .limit(5)
      .map { |appointment| recent_appointment_json(appointment) }
  end

  def recent_appointment_json(appointment)
    {
      id: appointment.id,
      client_id: appointment.client_id,
      scheduled_at: appointment.convert_time,
    }
  end

  def user_json(user)
    user.as_json(only: [:id, :account_id, :role, :first_name, :last_name, :email])
  end

  def set_user
    @user = current_account.users.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :role,
      :password,
      :password_confirmation
    )
  end
end
