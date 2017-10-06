class PackCatalogItem < ApplicationRecord
  belongs_to :pack, inverse_of: :pack_catalog_items, touch: true
  belongs_to :catalog_item

  validates :amount, numericality: { greater_than: 0, less_than_or_equal_to: (->(item) { item.pack.event.maximum_gtag_balance }) }

  validate :limit_amount, if: :infinite?
  validate :packception

  private

  def packception
    errors[:catalog_item] << "Cannot be a pack" if catalog_item.is_a?(Pack)
  end

  def infinite?
    catalog_item.infinite? if catalog_item.is_a?(Access)
  end

  def limit_amount
    errors[:amount] << "Infinite accesses cannot have amount different to 1" if amount != 1
  end
end
