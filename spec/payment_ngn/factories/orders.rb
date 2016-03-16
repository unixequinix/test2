# == Schema Information
#
# Table name: orders
#
#  id                        :integer          not null, primary key
#  number                    :string           not null
#  aasm_state                :string           not null
#  completed_at              :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  customer_event_profile_id :integer
#

FactoryGirl.define do
  factory :order do
    number { rand(10) }
    customer_event_profile

    trait :with_different_items do
      after :build do |order|
        order.order_items << build(:order_item, :with_access, order: order, amount: 10, total: 20)
        order.order_items << build(:order_item, :with_voucher, order: order, amount: 10, total: 40)
        order.order_items << build(:order_item, :with_voucher, order: order, amount: 10, total: 60)
      end
    end

    trait :with_credit do
      after :build do |order|
        order.order_items << build(:order_item, :with_credit, order: order, amount: 10, total: 20)
      end
    end

  end
end
