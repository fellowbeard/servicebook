module Api
  module V1
    class ResourcesController < BaseController
      before_action :require_write_access, only: [:create, :update, :destroy]
      before_action :set_resource, only: [:show, :update, :destroy]

      def index
        resources = current_account.resources.order(:name)

        render json: resources
      end

      def show
        render json: @resource
      end

      def create
        resource = current_account.resources.new(resource_params)

        if resource.save
          render json: resource, status: :created
        else
          render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @resource.update(resource_params)
          render json: @resource
        else
          render json: { errors: @resource.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @resource.destroy
        head :no_content
      end

      private

      def set_resource
        @resource = current_account.resources.find(params[:id])
      end

      def resource_params
        params.require(:resource).permit(:name)
      end
    end
  end
end