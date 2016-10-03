FactoryGirl.define do
  factory :access do
    after(:build) do |access|
      access.catalog_item ||= build(:catalog_item, catalogable: access)
      access.entitlement ||= build(:entitlement,
                                   entitlementable: access,
                                   event: access.catalog_item.event)
    end
  end
end
