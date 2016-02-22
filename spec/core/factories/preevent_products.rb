FactoryGirl.define do
  factory :preevent_product do
    event
    name { "Random name #{rand(100)}" }
    initial_amount 0
    online true
    step { rand(5) }
    max_purchasable { rand(50) }
    min_purchasable { rand(5) }
    price { rand(10.30) }

    trait :credit_product do
      after(:build) do |product|
        credit = build(:preevent_item_credit, event: product.event)
        product.preevent_product_items << build(:preevent_product_item,
                                                preevent_product: product,
                                                preevent_item: credit)
      end
    end

    trait :credential_product do
      after(:build) do |product|
        credential = build(:preevent_item_credential, event: product.event)
        product.preevent_product_items << build(:preevent_product_item,
                                                preevent_product: product,
                                                preevent_item: credential)
      end
    end

    trait :standard_credit_product do
      after(:build) do |product|
        credit = build(:preevent_item_standard_credit, event: product.event)
        product.preevent_product_items << build(:preevent_product_item,
                                                preevent_product: product,
                                                preevent_item: credit)
      end
    end

    trait :voucher_product do
      after(:build) do |product|
        voucher = build(:preevent_item_voucher, event: product.event)
        product.preevent_product_items << build(:preevent_product_item,
                                                preevent_product: product,
                                                preevent_item: voucher)
      end
    end

    trait :not_online do
      online false
    end

    trait :full do
      credit_product
      credential_product
      voucher_product
    end
  end
end
