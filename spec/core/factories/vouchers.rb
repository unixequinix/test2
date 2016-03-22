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
    after(:build) do |voucher|
      voucher.entitlement ||= build(:entitlement,
                                    entitlementable: voucher,
                                    event: voucher.catalog_item.event)
    end
  end
end
