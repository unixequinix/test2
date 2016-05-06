FactoryGirl.define do
  factory :catalog_item do
    event
    name { "Random name #{rand(100)}" }
    description { "Random name #{rand(100)}" }
    initial_amount 0
    step { rand(5) }
    max_purchasable 1
    min_purchasable 0

    trait :with_credit do
      after(:build) do |catalog_item|
        catalog_item.catalogable ||= build(:credit, catalog_item: catalog_item)
      end
    end

    trait :with_pack do
      after(:build) do |catalog_item|
        catalog_item.catalogable ||= build(:full_pack, catalog_item: catalog_item)
      end
    end

    trait :with_empty_pack do
      after(:build) do |catalog_item|
        catalog_item.catalogable ||= build(:empty_pack, catalog_item: catalog_item)
      end
    end

    trait :with_standard_credit do
      after(:build) do |catalog_item|
        catalog_item.catalogable ||= build(:standard_credit, catalog_item: catalog_item)
      end
    end

    trait :with_access do
      after(:build) do |catalog_item|
        catalog_item.catalogable ||= create(:access, catalog_item: catalog_item)
      end
    end

    trait :with_voucher do
      after(:build) do |catalog_item|
        catalog_item.catalogable ||= build(:voucher, :with_finite_entitlement,
                                           catalog_item: catalog_item)
      end
    end

    trait :with_voucher_infinite_entitlement do
      after(:build) do |catalog_item|
        catalog_item.catalogable ||= build(:voucher, :with_infinite_entitlement,
                                           catalog_item: catalog_item)
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
    factory :voucher_catalog_item_infinite_entitlement, traits: [:with_voucher_infinite_entitlement]
    factory :product_catalog_item, traits: [:with_onsite_catalog_item]
    factory :pack_item_catalog_item, traits: [:with_pack]
    factory :full_catalog_item, traits: [:with_credit, :with_access, :with_voucher]
  end
end
