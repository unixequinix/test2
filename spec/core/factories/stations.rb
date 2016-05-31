FactoryGirl.define do
  factory :station do
    event
    name { "Station #{rand(100)}" }
  end
end
