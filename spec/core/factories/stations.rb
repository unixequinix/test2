FactoryGirl.define do
  factory :station do
    event
    station_type
    name { "Station #{rand(100)}" }
  end
end
