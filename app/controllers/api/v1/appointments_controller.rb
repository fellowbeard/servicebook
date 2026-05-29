module Api
  module V1
    class AppointmentsController < BaseController
      before_action :set_appointment, only: %i[show update destroy]

      def index
        appointments = Appointment.includes(:services)
        render json: appointments.map(&:with_services)
      end

      def show
        render json: @appointment.with_services
      end

      def create
        appointment = Appointment.new(appointment_params)
        if appointment.save
          render json: appointment, status: :created
        else
          render json: { errors: appointment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @appointment.update(appointment_params)
          render json: @appointment
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
        params.require(:appointment).permit(:client_id, :scheduled_at, service: [])
      end
    end
  end
end
