class Access < ActiveRecord::Base
  has_one :catalog_item, as: :catalogable, dependent: :destroy
  has_one :entitlement, as: :entitlementable, dependent: :destroy
end