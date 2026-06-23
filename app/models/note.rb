class Note < ApplicationRecord
  belongs_to :user
  belongs_to :client

  validates :body, presence: true
  validates :user, presence: true
  validates :client, presence: true
end
