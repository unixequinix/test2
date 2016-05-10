# == Schema Information
#
# Table name: order_items
#
#  id              :integer          not null, primary key
#  order_id        :integer          not null
#  catalog_item_id :integer          not null
#  amount          :integer
#  total           :decimal(8, 2)    not null
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class OrderItem < ActiveRecord::Base
  # Associations
  belongs_to :order
  belongs_to :catalog_item

  def single_credits?
    catalog_item.catalogable_type == "Credit"
  end

  def pack_with_credits?
    catalog_item.catalogable_type == "Pack" && catalog_item.catalogable.credits.any?
  end

  def credits
    return amount if single_credits?
    return amount * catalog_item.catalogable.credits if pack_with_credits?
  end

  # Validations
  validates :amount, numericality: { only_integer: true, less_than_or_equal_to: 500 }
end
