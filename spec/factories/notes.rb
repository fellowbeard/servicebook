FactoryBot.define do
  factory :note do
    association :client
    association :user
    body { 'This is a test note' }
  end
end
