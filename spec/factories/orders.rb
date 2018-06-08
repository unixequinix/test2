FactoryBot.define do
  factory :order do
    event
    gateway "paypal"
    customer { build(:customer, event: event) }

    after :build do |order|
      order.order_items << build(:order_item, :with_access, order: order, amount: rand(1..100))
    end

    trait :with_different_items do
      after :build do |order|
        order.order_items << build(:order_item, :with_access, order: order, amount: rand(1..100))
      end

      after :build do |order|
        order.order_items << build(:order_item, :with_credit, order: order, amount: rand(1..100))
      end
    end

    trait :with_credit do
      after :build do |order|
        order.order_items << build(:order_item, :with_credit, order: order, amount: rand(1..100))
      end
    end

    trait :with_virtual_credit do
      after :build do |order|
        order.order_items << build(:order_item, :with_virtual_credit, order: order, amount: rand(1..100))
      end
    end

    trait :with_pack do
      transient do
        pack nil
      end

      after :build do |order, instance|
        order.order_items << create(:order_item, catalog_item_id: instance.pack.id, amount: 1)
      end
    end

    factory :order_with_items, traits: [:with_different_items]
  end
end
