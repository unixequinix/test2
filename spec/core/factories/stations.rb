FactoryGirl.define do
  factory :station do
    event
    station_type
    name { "word #{rand(100)}" }
  end
end
