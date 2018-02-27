FactoryBot.define do
  factory :order_item do
    amount 9
    order
    redeemed false

    trait :with_pack do
      after(:build) do |order_item|
        order_item.catalog_item ||= build(:pack)
        order_item.counter ||= 1
      end
    end

    trait :with_access do
      after(:build) do |order_item|
        order_item.catalog_item ||= build(:access)
        order_item.counter ||= 1
      end
    end

    trait :with_credit do
      after(:build) do |order_item|
        order_item.catalog_item ||= build(:credit)
        order_item.counter ||= 1
      end
    end
  end
end
