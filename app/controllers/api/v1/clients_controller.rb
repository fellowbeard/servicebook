module Api
  module V1
    class ClientsController < BaseController
      before_action :require_current_user
      before_action :require_write_access, only: [:create, :update, :destroy]
      before_action :set_client, only: [:show, :update, :destroy]

      def set_client
        @client = Client.find(params[:id])
      end

      def index
        clients = Client.all.limit(100)
        render json: clients.map { |client| ClientSerializer.new(client).as_json }
      end

      def show
        render json: ClientDetailSerializer.new(@client).as_json
      end

      def create
        client = current_user.clients.new(client_params)
        client.account = current_user.account        
        if client.save
          render json: ClientSerializer.new(client).as_json, status: :created
        else
          render json: { errors: client.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @client.update(client_params)
          render json: ClientSerializer.new(@client).as_json
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
