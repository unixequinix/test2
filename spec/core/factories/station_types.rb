FactoryGirl.define do
  factory :station_type do
    station_group
    name { "#{rand(100)} a name" }
    environment { "#{rand(100)} an environment" }
    description { "#{rand(100)} a description" }
  end
end
