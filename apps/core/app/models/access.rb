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
  before_validation :set_infinite_values, if: :infinite?
  before_validation :set_memory_length
  validate :min_max_congruency

  private

  def infinite?
    entitlement.infinite?
  end

  def set_infinite_values
    catalog_item.min_purchasable = 0
    catalog_item.max_purchasable = 1
    catalog_item.step = 1
    catalog_item.initial_amount = 0
  end

  def set_memory_length
    entitlement.memory_length = 2 if catalog_item.max_purchasable > 7
  end

  def min_max_congruency
    return if catalog_item.min_purchasable <= catalog_item.max_purchasable
    errors[:min_purchasable] << I18n.t("errors.messages.greater_than_maximum")
  end
end
