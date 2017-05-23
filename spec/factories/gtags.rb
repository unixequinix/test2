FactoryGirl.define do
  factory :gtag do
    event
    sequence(:tag_uid) { |n| "TAGUID#{n}" }
  end
end
