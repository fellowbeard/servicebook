class Account < ApplicationRecord
  has_many :users, dependent: :destroy

  validates :business_name, presence: true
end
