module Api
  module V1
    class ServicesController < BaseController
      before_action :set_service, only: %i[show update destroy]

      def index
        services = Service.all
        render json: services.map { |service| ServiceSerializer.new(service).as_json }
      end

      def show
        render json: ServiceSerializer.new(@service).as_json
      end

      def create
        service = Service.new(service_params)
        if service.save
          render json: ServiceSerializer.new(service).as_json, status: :created
        else
          render json: { errors: service.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @service.update(service_params)
          render json: ServiceSerializer.new(@service).as_json
        else
          render json: { errors: @service.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @service.destroy
        head :no_content
      end

      private

      def set_service
        @service = Service.find(params[:id])
      end

      def service_params
        params.require(:service).permit(:user_id, :title, :price, :duration_minutes, :description)
      end
    end
  end
end
