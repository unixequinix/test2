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

  def credits_included
    if catalog_item.catalogable_type == "Pack"
      pack_credits
    elsif catalog_item.catalogable_type == "Credit"
      single_credits
    else
      0
    end
  end

  def pack_credits
    catalog_item.catalogable.credits * amount
  end

  def single_credits
    amount
  end

  def credits?
    catalog_item.catalogable_type == "Credit" ||
      catalog_item.catalogable_type == "Pack" && catalog_item.catalogable.credits > 0
  end

  # Validations
  validates :amount, numericality: { only_integer: true, less_than_or_equal_to: 500 }
end
