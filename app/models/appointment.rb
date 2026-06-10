class Appointment < ApplicationRecord
  belongs_to :client
  
  has_many :appointment_services, dependent: :destroy
  has_many :services, through: :appointment_services

  STATUS_OPTIONS = ["scheduled", "completed", "canceled"]

  validates :scheduled_at, presence: true
  validates :status, presence: true, inclusion: { in: STATUS_OPTIONS }

  def convert_time
    self.scheduled_at.strftime("%A, %B %d, %Y")
  end
end
