FactoryGirl.define do
  factory :order do
    customer
    event

    trait :with_different_items do
      after :build do |order|
        order.order_items << build(:order_item, :with_access, order: order, amount: rand(500.00), total: rand(500.00))
      end
    end

    trait :with_credit do
      after :build do |order|
        order.order_items << build(:order_item, :with_credit, order: order, amount: rand(500), total: rand(50.00))
      end
    end

    factory :order_with_items, traits: [:with_different_items]
  end
end
