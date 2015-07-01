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

class OrderItem < ActiveRecord::Base
  # Associations
  belongs_to :order
  belongs_to :online_product

  # Validations
  validates :amount, numericality: { only_integer: true }
end
