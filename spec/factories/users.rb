FactoryBot.define do
  factory :user do
    name  {Faker::Name.initials(number: 2)}
    email {Faker::Internet.email}
    password  {"j3" + Faker::Internet.password(min_length: 6)}
    password_confirmation {password}
  end
end
