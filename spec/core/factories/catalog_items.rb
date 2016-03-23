FactoryGirl.define do
  factory :catalog_item do
    event
    name { "Random name #{rand(100)}" }
    description { "Random name #{rand(100)}" }
    initial_amount 0
    step { rand(5) }
    max_purchasable { rand(50) }
    min_purchasable { rand(5) }

    trait :with_credit do
      after(:build) do |catalog_item|
        catalog_item.catalogable ||= build(:credit, catalog_item: catalog_item)
      end
    end

    trait :with_pack do
      after(:build) do |catalog_item|
        catalog_item.catalogable ||= build(:pack, catalog_item: catalog_item)
      end
    end

    trait :with_standard_credit do
      after(:build) do |catalog_item|
        catalog_item.catalogable ||= build(:standard_credit, catalog_item: catalog_item)
      end
    end

    trait :with_access do
      after(:build) do |catalog_item|
        catalog_item.catalogable ||= build(:access, catalog_item: catalog_item)
      end
    end

    trait :with_voucher do
      after(:build) do |catalog_item|
        catalog_item.catalogable ||= build(:voucher, catalog_item: catalog_item)
      end
    end

    trait :with_product do
      after(:build) do |catalog_item|
        catalog_item.catalogable ||= build(:product, catalog_item: catalog_item)
      end
    end

    trait :with_credential_type do
      after(:build) do |catalog_item|
        build(:credential_type, catalog_item: catalog_item)
      end
    end

    factory :credit_catalog_item, traits: [:with_credit]
    factory :standard_credit_catalog_item, traits: [:with_standard_credit]
    factory :access_catalog_item, traits: [:with_access]
    factory :voucher_catalog_item, traits: [:with_voucher]
    factory :product_catalog_item, traits: [:with_onsite_catalog_item]
    factory :full_catalog_item, traits: [:with_credit, :with_access, :with_voucher]
  end
end
