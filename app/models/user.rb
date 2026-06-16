class User < ApplicationRecord
  has_secure_password
  validates :email, uniqueness: true, presence: true
  belongs_to :account
  has_many :services, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :clients, dependent: :destroy
  has_many :appointments, dependent: :nullify


  ROLES = ["owner", "staff", "read_only"]

  validates :role, inclusion: { in: ROLES }

  def owner?
    role == "owner"
  end

  def staff?
    role == "staff"
  end

  def read_only?
    role == "read_only"
  end

  def can_write?
    owner? || staff?
  end
end
