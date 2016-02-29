# == Schema Information
#
# Table name: vouchers
#
#  id         :integer          not null, primary key
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Voucher < ActiveRecord::Base
  acts_as_paranoid

  has_one :entitlement, as: :entitlementable, dependent: :destroy
  has_one :catalog_item, as: :catalogable, dependent: :destroy
  accepts_nested_attributes_for :catalog_item, allow_destroy: true
  accepts_nested_attributes_for :entitlement, allow_destroy: true
  has_and_belongs_to_many :products

  # Validations
  validates :catalog_item, presence: true
end
