class Client < ApplicationRecord
  has_many :services, dependent: :destroy
  has_many :appointments, dependent: :destroy
  has_many :notes, dependent: :destroy
end
