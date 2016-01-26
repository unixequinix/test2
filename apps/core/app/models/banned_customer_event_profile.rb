class BannedCustomerEventProfile < ActiveRecord::Base
  belongs_to :customer_event_profile
  validates :customer_event_profile_id, uniqueness: true
end
