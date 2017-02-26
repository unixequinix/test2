FactoryGirl.define do
  factory :gtag do
    event
    credits 0
    refundable_credits 0
    final_balance 0
    final_refundable_balance 0
    sequence(:tag_uid) { |n| "TAGUID#{n}" }
  end
end
