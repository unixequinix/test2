

FactoryGirl.define do
  factory :preevent_product do
    name { Faker::Number.between(1, 20) }
    online { [true, false].sample }
    event
    name { Faker::Name.last_name }
    initial_amount 0
    online true
    step { Faker::Number.between(1, 5) }
    max_purchasable { 10 * Faker::Number.between(2, 5) }
    min_purchasable { Faker::Number.between(1, 5) }
    price { Faker::Commerce.price }

    trait :credit_product do
      after(:build) do |preevent_product|
        preevent_product.preevent_product_items << build(:preevent_product_item,
                                                         preevent_product: preevent_product,
                                                         preevent_item: build(:preevent_item_credit, event: preevent_product.event))
      end
    end

    trait :credential_product do
      after(:build) do |preevent_product|
        preevent_product.preevent_product_items << build(:preevent_product_item,
                                                         preevent_product: preevent_product,
                                                         preevent_item: build(:preevent_item_credential, event: preevent_product.event))
      end
    end

    trait :standard_credit_product do
      after(:build) do |preevent_product|
        preevent_product.preevent_product_items << build(:preevent_product_item,
                                                         preevent_product: preevent_product,
                                                         preevent_item: build(:preevent_item_standard_credit, event: preevent_product.event))
      end
    end

    trait :voucher_product do
      after(:build) do |preevent_product|
        preevent_product.preevent_product_items << build(:preevent_product_item,
                                                         preevent_product: preevent_product,
                                                         preevent_item: build(:preevent_item_voucher, event: preevent_product.event))
      end
    end

    trait :not_online do
      online false
    end

    after(:create) do |preevent_product|
      preevent_product.preevent_items_counter
    end

    trait :full do
      credit_product
      credential_product
      voucher_product
    end
  end
end
