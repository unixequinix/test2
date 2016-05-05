FactoryGirl.define do
  factory :entitlement do
    mode { "counter" }
    memory_position { rand(100) }
    memory_length { rand(1..2) }

    trait :infinite do
      mode { "permanent" }
    end

    trait :permanent do
      mode { "permanent" }
    end

    trait :strict_permanent do
      mode { "strict_permanent" }
    end
  end
end
