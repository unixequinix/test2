FactoryGirl.define do
  factory :entitlement do
    infinite { false }
    memory_position { rand(100) }
    memory_length { rand(1..2) }

    trait :infinite do
      infinite { true }
    end
  end
end
