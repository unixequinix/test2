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
#  profile_id :integer
#

FactoryGirl.define do
  factory :order do
    number { rand(10_000).to_s + rand(10_000).to_s }
    profile

    trait :with_different_items do
      after :build do |order|
        order.order_items << build(:order_item, :with_access, order: order, amount: rand(500.00), total: rand(500.00))
        order.order_items << build(:order_item, :with_voucher, order: order, amount: rand(500.00), total: rand(500.00))
        order.order_items << build(:order_item, :with_voucher, order: order, amount: rand(500.00), total: rand(500.00))
      end
    end

    trait :with_credit do
      after :build do |order|
        order.order_items << build(:order_item, :with_credit, order: order, amount: rand(500), total: rand(50.00))
      end
    end
    factory :order_with_items, traits: [:with_different_items]

    trait :with_payment do
      after :build do |order|
        order.payments << build(:payment, order: order)
      end
    end
    factory :order_with_payment, traits: [:with_payment, :with_different_items]

    trait :with_direct_payment do
      after :build do |order|
        order.payments << build(:payment, order: order, payment_type: Payment::DIRECT_TYPES.sample)
      end
    end
    factory :order_with_direct_payment, traits: [:with_direct_payment, :with_different_items]
  end
end
