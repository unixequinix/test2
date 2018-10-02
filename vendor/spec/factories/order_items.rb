FactoryBot.define do
  factory :order_item do
    amount { 9 }
    order
    redeemed { false }

    trait :with_pack do
      after(:build) do |order_item|
        order_item.catalog_item ||= build(:pack, event: order_item.order.event)
        order_item.counter ||= 1
      end
    end

    trait :with_access do
      after(:build) do |order_item|
        order_item.catalog_item ||= build(:access, event: order_item.order.event)
        order_item.counter ||= 1
      end
    end

    trait :with_credit do
      after(:build) do |order_item|
        order_item.catalog_item ||= (order_item.order.event.credit || build(:credit, event: order_item.order.event))
        order_item.counter ||= 1
      end
    end

    trait :with_virtual_credit do
      after(:build) do |order_item|
        order_item.catalog_item ||= (order_item.order.event.virtual_credit || build(:virtual_credit, event: order_item.order.event))
        order_item.counter ||= 1
      end
    end

    trait :with_token do
      after(:build) do |order_item|
        order_item.catalog_item ||= (order_item.order.event.tokens.first || build(:token, event: order_item.order.event))
        order_item.counter ||= 1
      end
    end
  end
end
