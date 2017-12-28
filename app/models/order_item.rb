class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :catalog_item

  validates :total, :counter, presence: true

  def single_credits?
    catalog_item.is_a?(Credit)
  end

  def credits
    amount * catalog_item.credits
  end

  def virtual_credits
    amount * catalog_item.virtual_credits
  end

  def total_formatted
    format("%.2f", total)
  end
end
