# == Schema Information
#
# Table name: order_items
#
#  id              :integer          not null, primary key
#  order_id        :integer          not null
#  catalog_item_id :integer          not null
#  amount          :integer
#  total           :decimal(8, 2)    not null
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

FactoryGirl.define do
  factory :order_item do
    amount 9
    total "9.99"
    order

    trait :with_pack do
      after(:build) do |order_item|
        order_item.catalog_item ||= build(:pack_catalog_item)
      end
    end

    trait :with_access do
      after(:build) do |order_item|
        order_item.catalog_item ||= build(:access_catalog_item)
      end
    end

    trait :with_voucher do
      after(:build) do |order_item|
        order_item.catalog_item ||= build(:voucher_catalog_item)
      end
    end

    trait :with_credit do
      after(:build) do |order_item|
        order_item.catalog_item ||= build(:credit_catalog_item)
      end
    end
  end
end
