# == Schema Information
#
# Table name: credential_transactions
#
#  id                        :integer          not null, primary key
#  ticket_id                 :integer
#  preevent_product_id       :integer
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

class CredentialTransaction < ActiveRecord::Base
  belongs_to :event
  belongs_to :station
  belongs_to :device
  belongs_to :customer_event_profile
  belongs_to :preevent_product
  belongs_to :ticket

  validates_presence_of :transaction_type
end
