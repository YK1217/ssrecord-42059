FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "user_#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { '8PESeFzZ87TF' }
    password_confirmation { password }
  end
end
