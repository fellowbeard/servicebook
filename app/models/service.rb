class Service < ApplicationRecord
  belongs_to :account
  belongs_to :user, optional: true

  has_many :appointment_services, dependent: :destroy
  has_many :appointments, through: :appointment_services

  scope :alphabetical, lambda { order(:title) }
end
