class Api::V1::AccountsController < BaseController
  before_action :require_owner, only: [:update]

  def show
    render json: AccountSerializer.new(current_account).as_json
  end

  def update
    if current_account.update(account_params)
      render json: AccountSerializer.new(current_account).as_json
    else
      render json: { errors: current_account.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def account_params
    params.require(:account).permit(:business_name)
  end
end
