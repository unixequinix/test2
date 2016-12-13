FactoryGirl.define do
  factory :access do
    event
    sequence(:name) { |n| "Access #{n}" }
    initial_amount 0
    step 1
    max_purchasable 1
    min_purchasable 0

    after(:build) do |access|
      access.entitlement ||= build(:entitlement, event: access.event)
    end
  end
end
