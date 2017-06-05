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

  def total_formatted
    format("%.2f", total)
  end

  def refundable_credits
    return credits unless catalog_item.is_a?(Pack)
    return 0 unless catalog_item.only_credits?
    total / catalog_item.catalog_items.first.value
  end
end
