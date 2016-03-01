# == Schema Information
#
# Table name: banned_customer_event_profiles
#
#  id                        :integer          not null, primary key
#  customer_event_profile_id :integer          not null
#  deleted_at                :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class BannedCustomerEventProfile < ActiveRecord::Base
  belongs_to :customer_event_profile
  validates :customer_event_profile_id, uniqueness: true
end
