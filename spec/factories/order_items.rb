# == Schema Information
#
# Table name: order_items
#
#  amount          :decimal(8, 2)
#  counter         :integer
#  redeemed        :boolean
#  total           :decimal(8, 2)    not null
#
# Indexes
#
#  index_order_items_on_catalog_item_id  (catalog_item_id)
#  index_order_items_on_order_id         (order_id)
#
# Foreign Keys
#
#  fk_rails_d59832cd1f  (catalog_item_id => catalog_items.id)
#  fk_rails_e3cb28f071  (order_id => orders.id)
#

FactoryGirl.define do
  factory :order_item do
    amount 9
    total "9.99"
    order
    redeemed false

    trait :with_pack do
      after(:build) do |order_item|
        order_item.catalog_item ||= build(:pack)
        order_item.counter ||= 1
      end
    end

    trait :with_access do
      after(:build) do |order_item|
        order_item.catalog_item ||= build(:access)
        order_item.counter ||= 1
      end
    end

    trait :with_credit do
      after(:build) do |order_item|
        order_item.catalog_item ||= build(:credit)
        order_item.counter ||= 1
      end
    end
  end
end
