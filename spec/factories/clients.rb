FactoryBot.define do
  factory :client do
    association :account
    association :user
    first_name { 'Jane' }
    last_name { 'Doe' }
    sequence(:email) { |n| "client#{n}@example.com" }
    phone { '555-1212' }
  end
end
