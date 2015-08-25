# == Schema Information
#
# Table name: orders
#
#  id                        :integer          not null, primary key
#  customer_event_profile_id :integer          not null
#  number                    :string           not null
#  aasm_state                :string           not null
#  completed_at              :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

FactoryGirl.define do
  factory :order do
    number { Faker::Number.number(10) }
    aasm_state 'started'
    customer

    transient do
      item_count 3
    end

    after :build do |order|
      order.order_items << FactoryGirl.build(:order_item, order: order)
    end
  end
end
