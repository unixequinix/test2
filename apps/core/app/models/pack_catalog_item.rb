# == Schema Information
#
# Table name: pack_catalog_items
#
#  id              :integer          not null, primary key
#  pack_id         :integer          not null
#  catalog_item_id :integer          not null
#  amount          :decimal(8, 2)
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class PackCatalogItem < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :pack, counter_cache: :catalog_items_count, inverse_of: :pack_catalog_items
  belongs_to :catalog_item

  validates :amount, presence: true
  validates :amount, numericality: true
  validate :limit_amount, if: :infinite?

  private

  def infinite?
    type = catalog_item.catalogable_type
    catalog_item.catalogable.entitlement.infinite? if %w(Access Voucher).include?(type)
  end

  def limit_amount
    return if amount.is_a?(Numeric) && amount.between?(0, 1)
    errors[:amount] << I18n.t("errors.messages.invalid_max_value_for_infinite")
  end
end
