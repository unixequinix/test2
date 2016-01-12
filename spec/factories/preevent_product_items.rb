# == Schema Information
#
# Table name: preevent_product_items
#
#  id                  :integer          not null, primary key
#  preevent_item_id    :integer
#  preevent_product_id :integer
#  amount              :integer
#  deleted_at          :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

FactoryGirl.define do
  factory :preevent_product_item do
    amount { Faker::Number.between(1, 20) }
    preevent_item
    preevent_product
  end
end
