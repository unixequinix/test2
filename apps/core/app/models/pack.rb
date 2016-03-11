# == Schema Information
#
# Table name: packs
#
#  id                  :integer          not null, primary key
#  catalog_items_count :integer          default(0), not null
#  deleted_at          :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Pack < ActiveRecord::Base
  acts_as_paranoid

  has_one :catalog_item, as: :catalogable, dependent: :destroy
  accepts_nested_attributes_for :catalog_item, allow_destroy: true

  has_many :pack_catalog_items, dependent: :destroy
  has_many :catalog_items_included, through: :pack_catalog_items, source: :catalog_item
  accepts_nested_attributes_for :pack_catalog_items, allow_destroy: true

  # Scope

  scope :credentiable_packs, lambda {
    joins(:catalog_items_included)
      .where(catalog_items: {
               catalogable_type: CatalogItem::CREDENTIABLE_TYPES })
  }

  def credits
    catalog_items_included
      .joins(:pack_catalog_items)
      .includes(:catalogable)
      .select("catalog_items.*", "sum(pack_catalog_items.amount)")
      .where(catalog_items: { catalogable_type: "Credit" })
      .group("catalog_items.name", "catalog_items.id")
  end

  def credits_pack?
    number_catalog_credit_items = catalog_items_included.where(catalogable_type: "Credit").count
    number_catalog_credit_items > 0 && number_catalog_credit_items == catalog_items_count
  end
end
