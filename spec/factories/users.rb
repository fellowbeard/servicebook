FactoryBot.define do
  factory :user do
    association :account
    first_name { 'Test' }
    last_name { 'User' }
    sequence(:email) { |n| "user#{n}@example.com" }
    role { 'owner' }
    password { 'password' }
    password_confirmation { 'password' }

    trait :staff do
      role { 'staff' }
    end

    trait :read_only do
      role { 'read_only' }
    end
  end
end
