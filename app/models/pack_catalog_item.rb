# == Schema Information
#
# Table name: pack_catalog_items
#
#  amount          :decimal(8, 2)
#
# Indexes
#
#  index_pack_catalog_items_on_catalog_item_id  (catalog_item_id)
#  index_pack_catalog_items_on_pack_id          (pack_id)
#
# Foreign Keys
#
#  fk_rails_b4c71ddbac  (catalog_item_id => catalog_items.id)
#

class PackCatalogItem < ActiveRecord::Base
  belongs_to :pack, inverse_of: :pack_catalog_items
  belongs_to :catalog_item

  validates :amount, presence: true
  validates :amount, numericality: true

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
