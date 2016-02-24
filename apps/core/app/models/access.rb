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
end
