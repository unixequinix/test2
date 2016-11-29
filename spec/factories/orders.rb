# == Schema Information
#
# Table name: orders
#
#  completed_at :datetime
#  created_at   :datetime         not null
#  gateway      :string
#  payment_data :json
#  status       :string           default("in_progress"), not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_orders_on_customer_id  (customer_id)
#
# Foreign Keys
#
#  fk_rails_3dad120da9  (customer_id => customers.id)
#

FactoryGirl.define do
  factory :order do
    customer

    trait :with_different_items do
      after :build do |order|
        order.order_items << build(:order_item, :with_access, order: order, amount: rand(500.00), total: rand(500.00))
      end
    end

    trait :with_credit do
      after :build do |order|
        order.order_items << build(:order_item, :with_credit, order: order, amount: rand(500), total: rand(50.00))
      end
    end

    factory :order_with_items, traits: [:with_different_items]
  end
end
