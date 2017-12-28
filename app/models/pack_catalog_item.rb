class PackCatalogItem < ApplicationRecord
  belongs_to :pack, inverse_of: :pack_catalog_items, touch: true
  belongs_to :catalog_item

  validates :amount, numericality: { greater_than: 0, less_than_or_equal_to: (->(item) { item.calculate_maximum_amount }) }

  validate :packception
  validate :operator_permissions_count
  validate :item_uniqueness

  def infinite?
    catalog_item.infinite? if catalog_item.is_a?(Access)
  end

  def calculate_maximum_amount
    result = 1
    result = pack.event.maximum_gtag_balance if catalog_item.is_a?(Credit)
    result = 42_000_000 if catalog_item.is_a?(VirtualCredit) # this is to do with memory restrictions in the gtag
    result = 127 if catalog_item.is_a?(Access) && catalog_item.counter?
    result
  end

  private

  def operator_permissions_count
    count = pack.pack_catalog_items.count { |item| item.catalog_item.is_a?(OperatorPermission) && !item.marked_for_destruction? }
    errors[:catalog_item_id] << 'Cannot have more than 8 operator permissions' if count > 8
  end

  def item_uniqueness
    condition = pack.pack_catalog_items.size != pack.pack_catalog_items.group_by(&:catalog_item_id).size
    errors[:catalog_item_id] << 'Cannot add the same item twice' if condition
  end

  def packception
    errors[:catalog_item] << "Cannot be a pack" if catalog_item.is_a?(Pack)
  end
end
