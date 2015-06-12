# == Schema Information
#
# Table name: order_items
#
#  id                :integer          not null, primary key
#  order_id          :integer          not null
#  online_product_id :integer          not null
#  amount            :integer
#  total             :decimal(8, 2)    not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

FactoryGirl.define do
  factory :order_item do
    price '9.99'
    total '9.99'
    online_product
    order
  end
end
