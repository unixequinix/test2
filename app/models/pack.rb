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

  has_many :pack_catalog_items, dependent: :destroy, inverse_of: :pack
  has_many :catalog_items_included, through: :pack_catalog_items, source: :catalog_item
  accepts_nested_attributes_for :pack_catalog_items, allow_destroy: true

  # Scope

  scope :credentiable_packs, lambda {
    joins(:catalog_items_included)
      .where(catalog_items: {
               catalogable_type: CatalogItem::CREDENTIABLE_TYPES
             })
  }

  validate :valid_max_value, if: :infinite_item?
  validate :valid_min_value, if: :infinite_item?
  validate :valid_max_credits

  def credits
    open_all("Credit").uniq(&:catalog_item_id)
  end

  def total_credits
    credits.sum(:total_amount).total_amount
  end

  def only_credits_pack?
    number_catalog_items = open_all.size
    number_catalog_credit_items = open_all.select do |catalog_item|
      catalog_item.catalogable_type == "Credit"
    end.size
    number_catalog_credit_items > 0 && number_catalog_credit_items == number_catalog_items
  end

  # TODO: To check
  def only_infinite_items_pack?
    number_catalog_items = open_all.size
    number_catalog_infinite_items = open_all("Access", "Voucher").select do |catalog_item|
      catalog_item.catalogable.entitlement.infinite?
    end.size
    number_catalog_infinite_items > 0 && number_catalog_infinite_items == number_catalog_items
  end

  # TODO: To check
  def open_all(*category)
    catalog_items_included_without_destruction_marked.each_with_object([]) do |catalog_item, result|
      if catalog_item.catalogable_type == "Pack"
        item_found = catalog_item.catalogable.open_all(*category)
        parent_pack_amount = catalog_item.pack_catalog_items.find_by(pack_id: id).amount
        item_found.first.total_amount *= parent_pack_amount
        result.push(item_found) if item_found
      elsif category.include?(catalog_item.catalogable_type) || category.blank?
        result.push(build_enriched_catalog_item(catalog_item))
      end
    end.flatten
  end

  # TODO: To check
  def build_enriched_catalog_item(catalog_item)
    Sorters::FakeCatalogItem.new(
      catalog_item_id: catalog_item.id,
      catalogable_id: catalog_item.catalogable_id,
      catalogable_type: catalog_item.catalogable_type,
      product_name: catalog_item.name,
      value: catalog_item.catalogable_type == "Credit" && catalog_item.catalogable.value,
      total_amount: catalog_item.pack_catalog_items.where(pack_id: id).sum(:amount)
    )
  end

  private

  def catalog_items_included_without_destruction_marked
    accepted_ids = pack_catalog_items.map do |e|
      e.catalog_item.id unless e.marked_for_destruction?
    end.compact
    catalog_items_included(true).where(id: accepted_ids)
  end

  def infinite_item?
    open_all.any? do |item|
      item.catalogable.entitlement.infinite? if %w(Access Voucher).include?(item.catalogable_type)
    end
  end

  def valid_max_value
    return if catalog_item.max_purchasable.between?(0, 1)
    errors[:max_purchasable] << I18n.t("errors.messages.invalid_max_value_for_infinite")
  end

  def valid_min_value
    return if catalog_item.min_purchasable.between?(0, 1)
    errors[:min_purchasable] << I18n.t("errors.messages.invalid_min_value_for_infinite")
  end

  def valid_max_credits
    return false unless catalog_item.present?
    max_balance = catalog_item.event.get_parameter("gtag", "form", "maximum_gtag_balance").to_i
    pack_credits = if persisted?
                     open_all("Credit").sum(&:total_amount)
                   else
                     pack_catalog_items.map { |i| i.amount.to_f }.sum
                   end

    error_msg = I18n.t("errors.messages.more_credits_than_max_balance")
    errors[:pack_credits] << error_msg if pack_credits > max_balance
  end
end
