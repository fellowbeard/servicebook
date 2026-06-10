module Api
  module V1
    class AppointmentsController < BaseController
      before_action :require_write_access, only: [:create, :update, :destroy]
      before_action :set_appointment, only: [:show, :update, :destroy]

      def index
        appointments = current_account.appointments.includes(:services)
        render json: appointments.map { |appointment| AppointmentSerializer.new(appointment).as_json }
      end

      def show
        render json: AppointmentSerializer.new(@appointment).as_json
      end

      def create
        appointment = Appointment.new(appointment_params)
        appointment.user = current_user
        appointment.account = current_user.account

        if appointment.save
          render json: AppointmentSerializer.new(appointment).as_json, status: :created
        else
          render json: { errors: appointment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @appointment.update(appointment_params)
          render json: AppointmentSerializer.new(@appointment).as_json
        else
          render json: { errors: @appointment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @appointment.destroy
        head :no_content
      end

      private

      def set_appointment
        @appointment = Appointment.find(params[:id])
      end

      def appointment_params
        params.require(:appointment).permit(
          :client_id,
          :resource_id,
          :scheduled_at,
          :status,
          service_ids: []
        )
      end
    end
  end
end
