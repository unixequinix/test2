FactoryGirl.define do
  factory :entitlement do
    mode { "counter" }
    memory_length { rand(1..2) }

    trait :infinite do
      mode { "permanent" }
    end

    trait :permanent do
      mode { "permanent" }
    end

    trait :permanent_strict do
      mode { "permanent_strict" }
    end

    trait :with_access do
      after(:build) do |entitlement|
        entitlement.entitlementable ||= build(:access)
      end
    end

    trait :with_voucher do
      after(:build) do |entitlement|
        entitlement.entitlementable ||= build(:voucher)
      end
    end
  end
end
