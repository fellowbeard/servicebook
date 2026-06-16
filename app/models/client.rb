class Client < ApplicationRecord
  belongs_to :account, optional: true
  belongs_to :user

  has_many :appointments, dependent: :destroy
  has_many :appointment_services, through: :appointments
  has_many :services, through: :appointment_services
  has_many :notes, dependent: :destroy

  scope :for_user, ->(user) {
    where(user_id: user.id)
  }
end