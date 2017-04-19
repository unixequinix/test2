class PackCatalogItem < ActiveRecord::Base
  belongs_to :pack, inverse_of: :pack_catalog_items
  belongs_to :catalog_item

  validates :amount, numericality: { less_than_or_equal_to: (->(item) { item.pack.event.maximum_gtag_balance }) }

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
    return if amount.is_a?(Numeric) && amount.between?(0, 1)
    errors[:amount] << I18n.t("errors.messages.invalid_max_value_for_infinite")
  end
end
