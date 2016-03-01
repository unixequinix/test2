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
end
