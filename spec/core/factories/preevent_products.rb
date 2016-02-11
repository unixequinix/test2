FactoryGirl.define do
  factory :preevent_product do
    event
    name { Faker::Name.last_name }
    initial_amount 0
    online true
    step { Faker::Number.between(1, 5) }
    max_purchasable { 10 * Faker::Number.between(2, 5) }
    min_purchasable { Faker::Number.between(1, 5) }
    price { Faker::Commerce.price }

    trait :credit_product do
      after(:build) do |product|
        credit = build(:preevent_item_credit, event: product.event)
        product.preevent_product_items << build(:preevent_product_item,
                                                reevent_product: product,
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

    after(:build) do |preevent_product|
      return unless preevent_product.preevent_items.count.zero?
      preevent_product.preevent_product_items << build(:preevent_product_item)
    end
  end
end
