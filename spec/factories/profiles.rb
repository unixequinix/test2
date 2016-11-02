FactoryGirl.define do
  factory :profile do
    event
    banned false
    credits 0
    refundable_credits 0
    final_balance 0
    final_refundable_balance 0

    trait :with_customer do
      after(:build) do |profile|
        profile.customer ||= build(:customer, profile: profile, event: profile.event)
      end
    end
  end
end
