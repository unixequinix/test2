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

    transient do
      item_count 3
    end

    after :build do |order|
      order.order_items << build(:order_item, order: order)
    end
  end
end
