FactoryGirl.define do
  factory :station do
    event
    sequence(:name) { |n| "Station #{n}" }
    category "customer_portal"
    group "access"
  end
end
