# == Schema Information
#
# Table name: vouchers
#
#  id         :integer          not null, primary key
#  counter    :integer          default(0), not null
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :voucher do
    trait :with_finite_entitlement do
      after(:build) do |voucher|
        voucher.entitlement ||= build(:entitlement,
                                      entitlementable: voucher,
                                      event: voucher.catalog_item.event)
      end
    end

    trait :with_infinite_entitlement do
      after(:build) do |voucher|
        voucher.entitlement ||= build(:entitlement, :infinite,
                                      entitlementable: voucher,
                                      event: voucher.catalog_item.event)
      end
    end
  end
end
