FactoryGirl.define do
  factory :company do
    sequence(:name) { |n| "Company #{n}" }
    event
    sequence(:access_token) { |n| "token#{n}" }
  end
end
