class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :catalog_item

  validates :counter, :amount, presence: true, numericality: true
  validates :amount, numericality: { greater_than: 0 }, unless: -> { catalog_item.is_a?(UserFlag) }

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
