module Api
  module V1
    class ClientsController < BaseController
      def index
        clients = Client.all.limit(100)
        render json: clients.as_json(only: [:id, :first_name, :last_name, :email, :phone])
      end

      def show
        client = Client.find(params[:id])
        render json: client.as_json(only: [:id, :first_name, :last_name, :email, :phone])
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
        client = Client.find(params[:id])
        if client.update(client_params)
          render json: client
        else
          render json: { errors: client.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        client = Client.find(params[:id])
        client.destroy
        head :no_content
      end

      private

      def client_params
        params.require(:client).permit(:first_name, :last_name, :email, :phone)
      end
    end
  end
end
