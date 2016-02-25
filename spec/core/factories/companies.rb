FactoryGirl.define do
  factory :company do
    name { "Company name #{rand(100)}" }
  end
end
