FactoryGirl.define do
  factory :access do
    event
    name { "Random name #{rand(100)}" }
    initial_amount 0
    step { rand(5) }
    max_purchasable 1
    min_purchasable 0

    after(:build) do |access|
      access.entitlement ||= build(:entitlement, event: access.event)
    end
  end
end
