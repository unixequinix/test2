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
    number { Faker::Number.number(10) }
    customer_event_profile

    after :build do |order, _evaluator|
      3.times do
        order.order_items << build(:order_item, order: order, total: 19.95)
      end
    end

    trait :empty_order_items do
      order_items = []
    end
  end
end
