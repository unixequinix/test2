# == Schema Information
#
# Table name: customer_orders
#
#  id                        :integer          not null, primary key
#  profile_id :integer          not null
#  catalog_item_id           :integer          not null
#  origin                    :string
#  amount                    :integer
#  deleted_at                :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

FactoryGirl.define do
  factory :customer_order do
    profile
    catalog_item
    origin "online_purchase"
    amount { rand(1..50) }

    trait :with_ticket_assignment_origin do
      origin "ticket_assignment"
    end

    trait :with_device_origin do
      origin "device"
    end

    trait :with_online_purchase_origin do
      origin "online_purchase"
    end
  end
end
