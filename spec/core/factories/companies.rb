FactoryGirl.define do
  factory :company do
    event
    name { Faker::Company.name }
  end
end
