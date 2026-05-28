class Service < ApplicationRecord
  belongs_to :user
  belongs_to :client
  has_many :appointment_services, dependent: :destroy
  has_many :appointments, through: :appointment_services
end
