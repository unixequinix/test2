FactoryGirl.define do
  factory :user_flag do
    event
    sequence(:name) { |n| "Flag #{n}" }
    step 1
  end
end
