# == Schema Information
#
# Table name: access_transactions
#
#  id                        :integer          not null, primary key
#  direction                 :integer
#  access_entitlement_id     :integer
#  access_entitlement_value  :integer
#  event_id                  :integer
#  transaction_type          :string
#  device_created_at         :datetime
#  customer_tag_uid          :string
#  operator_tag_uid          :string
#  station_id                :integer
#  device_db_index           :integer
#  customer_event_profile_id :integer
#  status_code               :string
#  status_message            :string
#  created_at                :datetime
#  updated_at                :datetime
#  device_uid                :string
#

class AccessTransaction < ActiveRecord::Base
  belongs_to :event
  belongs_to :station
  belongs_to :device
  belongs_to :customer_event_profile
  belongs_to :access_entitlement
end
