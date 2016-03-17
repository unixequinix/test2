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
    open_all("Credit").uniq(&:catalog_item_id)
  end

  def only_credits_pack?
    number_catalog_items = open_all.size
    number_catalog_credit_items = open_all.select do |catalog_item|
      catalog_item.catalogable_type == "Credit"
    end.size
    number_catalog_credit_items > 0 && number_catalog_credit_items == number_catalog_items
  end

  def open_all(*category)
    items = catalog_items_included.each_with_object([]) do |catalog_item, result|
      if catalog_item.catalogable_type == "Pack"
        item_found = catalog_item.catalogable.open_all
        parent_pack_amount = catalog_item.pack_catalog_items.where(pack_id: id).first.amount
        item_found.first.total_amount *= parent_pack_amount
        result.push(item_found) if item_found
      else
        result.push(build_catalog_item(catalog_item)) if category.include?(catalog_item.catalogable_type) || category.blank?
      end
    end
    items.flatten
  end

  def build_catalog_item(catalog_item)
    Sorters::FakeCatalogItem.new(
      catalog_item_id: catalog_item.id,
      catalogable_id: catalog_item.catalogable_id,
      catalogable_type: catalog_item.catalogable_type,
      product_name: catalog_item.name,
      value: catalog_item.catalogable_type == "Credit" && catalog_item.catalogable.value,
      total_amount: catalog_item.pack_catalog_items.where(pack_id: id).sum(:amount)
    )
  end
end
