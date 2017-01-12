FactoryGirl.define do
  factory :access do
    event
    sequence(:name) { |n| "Access #{n}" }
    initial_amount 0
    step 1
    max_purchasable 1
    min_purchasable 0
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
