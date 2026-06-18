require 'rails_helper'

RSpec.describe Account, type: :model do
  it 'requires a business name' do
    account = Account.new

    expect(account).not_to be_valid
    expect(account.errors[:business_name]).to include("can't be blank")
  end
end
