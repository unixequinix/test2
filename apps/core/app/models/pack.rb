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

  #Scope

  scope :credentiable_packs, -> { joins(:catalog_items_included)
                                  .where(catalog_items: {
                                         catalogable_type: CatalogItem::CREDENTIABLE_TYPES})
                                }

  def credits
    pack_catalog_items
      .joins(:catalog_item)
      .where(catalog_items: { catalogable_type: "Credit" })
      .sum(:amount)
  end
end
