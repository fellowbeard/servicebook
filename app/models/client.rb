class Client < ApplicationRecord
  belongs_to :user
  has_many :services, dependent: :destroy
  has_many :appointments, dependent: :destroy
  has_many :notes, dependent: :destroy

  scope :for_user, ->(user) {
    where(user_id: user.id)
  }
end
