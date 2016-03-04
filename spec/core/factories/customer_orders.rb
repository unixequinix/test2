# == Schema Information
#
# Table name: customer_orders
#
#  id                        :integer          not null, primary key
#  event_id                  :integer          not null
#  preevent_product_id       :integer          not null
#  customer_event_profile_id :integer          not null
#  counter                   :integer
#  aasm_state                :string           default("unredeemed"), not null
#  deleted_at                :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

FactoryGirl.define do
  factory :customer_order do
    customer_event_profile
    catalog_item
  end
end
