class Resource < ApplicationRecord
  belongs_to :account

  before_validation :normalize_name

  validates :name, presence: true
  validates :name, uniqueness: { scope: :account_id }

  private

  def normalize_name
    self.name = NameNormalizer.normalize(name)
  end
end
