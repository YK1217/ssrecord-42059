FactoryBot.define do
  factory :user do
    name  { Faker::Name.initials(number: 2) }
    email { Faker::Internet.email }
    password { '8PESeFzZ87TF' }
    password_confirmation { password }
  end
end
