module Api
  module V1
    class ClientsController < BaseController
      before_action :set_client, only: [:show, :update, :destroy]

      def set_client
        @client = Client.find(params[:id])
      end

      def index
        clients = Client.all.limit(100)
        render json: clients.as_json(only: [:id, :first_name, :last_name, :email, :phone])
      end

      def show
        render json: @client.as_json(
          only: [:id, :first_name, :last_name, :email],
          include: {
            services: {
              only: [:id, :title, :description, :duration_minutes, :price]
            },
            notes: {
              only: [:id, :body, :user_id, :created_at]
            },
            appointments: {
              only: [:id, :scheduled_at],
              include: {
                services: {
                  only: [:id, :title, :price, :duration_minutes]
                }
              }
            }
          }
        )
      end

      def create
        client = Client.new(client_params)
        if client.save
          render json: client, status: :created
        else
          render json: { errors: client.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @client.update(client_params)
          render json: @client
        else
          render json: { errors: @client.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @client.destroy
        head :no_content
      end

      private

      def client_params
        params.require(:client).permit(:first_name, :last_name, :email, :phone)
      end
    end
  end
end
