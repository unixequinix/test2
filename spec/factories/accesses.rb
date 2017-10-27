FactoryBot.define do
  factory :access do
    event
    sequence(:name) { |n| "Access #{n}" }
    mode Access::PERMANENT_STRICT

    trait :counter do
      mode Access::COUNTER
    end

    trait :permanent do
      mode Access::PERMANENT
    end

    trait :permanent_strict do
      mode Access::PERMANENT_STRICT
    end
  end
end
