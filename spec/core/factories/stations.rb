FactoryGirl.define do
  factory :station do
    event
    name { "Station #{rand(100)}" }
    category { "customer_portal" }
    group { "access" }
  end
end
