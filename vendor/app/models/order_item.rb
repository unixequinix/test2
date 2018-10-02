class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :catalog_item

  validates :counter, :amount, presence: true
  validates :counter, numericality: true
  validates :amount, numericality: true, unless: -> { catalog_item.is_a?(UserFlag) }

  scope :with_catalog_item, ->(catalog_items) { catalog_items.blank? ? all : where(catalog_item: catalog_items) }

  def credits
    amount * catalog_item.credits
  end

  def virtual_credits
    amount * catalog_item.virtual_credits
  end
end
