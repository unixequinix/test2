# == Schema Information
#
# Table name: order_items
#
#  amount          :decimal(8, 2)
#  counter         :integer
#  redeemed        :boolean
#  total           :decimal(8, 2)    not null
#
# Indexes
#
#  index_order_items_on_catalog_item_id  (catalog_item_id)
#  index_order_items_on_order_id         (order_id)
#
# Foreign Keys
#
#  fk_rails_d59832cd1f  (catalog_item_id => catalog_items.id)
#  fk_rails_e3cb28f071  (order_id => orders.id)
#

class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :catalog_item

  def single_credits?
    catalog_item.is_a?(Credit)
  end

  def pack_with_credits?
    catalog_item.is_a?(Pack) && catalog_item.credits.positive?
  end

  def credits
    amount * catalog_item.credits
  end

  def refundable_credits
    return credits unless catalog_item.is_a?(Pack)
    return 0 unless catalog_item.only_credits?
    total / catalog_item.catalog_items.first.value
  end
end
