FactoryGirl.define do
  factory :product do
    event
    sequence(:name) { |n| "Product #{n}" }
    sequence(:description) { |n| "Description #{n}" }
    is_alcohol false
  end
end
