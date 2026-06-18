require 'rails_helper'

RSpec.describe Resource, type: :model do
  it 'validates presence of a name' do
    resource = Resource.new

    expect(resource).not_to be_valid
    expect(resource.errors[:name]).to include("can't be blank")
  end
end
