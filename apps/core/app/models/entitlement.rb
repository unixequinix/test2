class Entitlement < ActiveRecord::Base
  belongs_to :entitlementable, polymorphic: true, touch: true
end