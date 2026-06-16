class Appointment < ApplicationRecord
  belongs_to :account
  belongs_to :user
  belongs_to :client
  belongs_to :resource

  has_many :appointment_services, dependent: :destroy
  has_many :services, through: :appointment_services

  STATUS_OPTIONS = ['scheduled', 'completed', 'canceled'].freeze
  UNKNOWN_DURATION_MINUTES = 60

  validates :scheduled_at, presence: true
  validates :status, presence: true, inclusion: { in: STATUS_OPTIONS }

  validate :must_have_at_least_one_service
  validate :scheduled_at_cannot_be_in_the_past
  validate :resource_is_available

  def convert_time
    scheduled_at.strftime('%A, %B %d, %Y')
  end

  def service_duration_minutes
    services.sum(:duration_minutes)
  end

  def blocking_reservation_time
    return self[:duration_minutes] if self[:duration_minutes].present?
    return service_duration_minutes if service_duration_minutes.positive?

    UNKNOWN_DURATION_MINUTES
  end

  def ends_at
    scheduled_at + blocking_reservation_time.minutes
  end

  def scheduled?
    status == 'scheduled'
  end

  def completed?
    status == 'completed'
  end

  def canceled?
    status == 'canceled'
  end

  def uses_default_duration?
    self[:duration_minutes].blank? && service_duration_minutes.zero?
  end

  private

  def must_have_at_least_one_service
    return if services.any?

    errors.add(:services, 'must include at least one service')
  end

  def scheduled_at_cannot_be_in_the_past
    return if scheduled_at.blank?
    return if completed? || canceled?
    return if scheduled_at >= Time.current

    errors.add(:scheduled_at, "can't be in the past")
  end

  def resource_is_available
    return if resource_id.blank?
    return if scheduled_at.blank?
    return if canceled?

    overlapping_appointment = account.appointments
                                     .includes(:services)
                                     .where(resource_id: resource_id)
                                     .where.not(id: id)
                                     .where.not(status: 'canceled')
                                     .detect do |appointment|
                                       scheduled_at < appointment.ends_at &&
                                         ends_at > appointment.scheduled_at
                                     end

    return unless overlapping_appointment

    errors.add(:base, 'Resource is already booked at the scheduled time')
  end
end
