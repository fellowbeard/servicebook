class Client < ApplicationRecord
  has_many :services, dependent: :destroy
  has_many :appointments, dependent: :destroy
  has_many :notes, dependent: :destroy

  scope :for_user, ->(user) {
    joins(:services)
      .where(services: { user_id: user.id })
      .distinct
  }
end
