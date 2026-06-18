FactoryBot.define do
  factory :account do
    sequence(:business_name) { |n| "Acme Corp #{n}" }
  end
end
