class Appointment < ApplicationRecord
  belongs_to :client
  
  has_many :appointment_services, dependent: :destroy
  has_many :services, through: :appointment_services

  def with_services
    as_json.merge(
      services: services.as_json(
        only: [:id, :title, :description, :duration_minutes, :price]
      )
    )
  end
end
