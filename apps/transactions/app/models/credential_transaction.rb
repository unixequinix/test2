# == Schema Information
#
# Table name: transactions
#
#  id                        :integer          not null, primary key
#  type                      :string           not null
#  event_id                  :integer
#  transaction_type          :string
#  device_created_at         :datetime
#  ticket_id                 :integer
#  customer_tag_uid          :string
#  operator_tag_uid          :string
#  station_id                :integer
#  device_id                 :integer
#  device_uid                :integer
#  preevent_product_id       :integer
#  customer_event_profile_id :integer
#  payment_method            :string
#  status_code               :string
#  status_message            :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  credits                   :integer
#  credits_refundable        :integer
#  value_credit              :integer
#  payment_gateway           :string
#  final_balance             :integer
#  final_refundable_balance  :integer
#  access_entitlement_id     :integer
#  direction                 :integer
#  access_entitlement_value  :integer
#

class CredentialTransaction < ActiveRecord::Base
  belongs_to :event
  belongs_to :station
  belongs_to :device
  belongs_to :customer_event_profile
  belongs_to :preevent_product
  belongs_to :ticket

  SUBSCRIPTIONS = { encoded_ticket_scan: :create_ticket,
                    encoded_ticket_assignment: [:create_ticket] }
end
