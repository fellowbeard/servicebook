class Account < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :clients, dependent: :destroy
  has_many :appointments, dependent: :destroy
  has_many :resources, dependent: :destroy
  has_many :services, dependent: :destroy

  validates :business_name, presence: true
end
