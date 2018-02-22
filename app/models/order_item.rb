class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :catalog_item

  validates :counter, :amount, presence: true
  validates :counter, numericality: true
  validates :amount, numericality: true, unless: -> { catalog_item.is_a?(UserFlag) }

  def credits
    amount * catalog_item.credits
  end

  def virtual_credits
    amount * catalog_item.virtual_credits
  end
end
