FactoryBot.define do
  factory :resource do
    association :account
    sequence(:name) { |n| "Resource #{n}" }
  end
end
