FactoryGirl.define do
  factory :company do
    event
    name { "Company name #{rand(100)}" }
  end
end
