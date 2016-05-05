# == Schema Information
#
# Table name: accesses
#
#  id         :integer          not null, primary key
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Access < ActiveRecord::Base
  has_one :catalog_item, as: :catalogable, dependent: :destroy
  has_one :entitlement, as: :entitlementable, dependent: :destroy
  has_one :credential_type, through: :catalog_item
  accepts_nested_attributes_for :catalog_item, allow_destroy: true
  accepts_nested_attributes_for :entitlement, allow_destroy: true
  validate :valid_max_value, if: :infinite?
  validate :valid_min_value, if: :infinite?

  private

  def infinite?
    entitlement.infinite?
  end

  def valid_max_value
    return if catalog_item.max_purchasable.between?(0, 1)
    errors[:max_purchasable] << I18n.t("errors.messages.invalid_max_value_for_infinite")
  end

  def valid_min_value
    return if catalog_item.min_purchasable.between?(0, 1)
    errors[:min_purchasable] << I18n.t("errors.messages.invalid_min_value_for_infinite")
  end
end
