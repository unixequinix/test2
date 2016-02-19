# == Schema Information
#
# Table name: monetary_transactions
#
#  id                        :integer          not null, primary key
#  credits                   :integer
#  credits_refundable        :integer
#  value_credit              :integer
#  payment_gateway           :string
#  payment_method            :string
#  final_balance             :integer
#  final_refundable_balance  :integer
#  event_id                  :integer
#  transaction_type          :string
#  device_created_at         :datetime
#  customer_tag_uid          :string
#  operator_tag_uid          :string
#  station_id                :integer
#  device_id                 :integer
#  device_uid                :integer
#  customer_event_profile_id :integer
#  status_code               :string
#  status_message            :string
#  created_at                :datetime
#  updated_at                :datetime
#

class MonetaryTransaction < ActiveRecord::Base
  belongs_to :event
  belongs_to :station
  belongs_to :device
  belongs_to :customer_event_profile
  has_many :line_items
  has_many :transaction_sale_items

  accepts_nested_attributes_for :transaction_sale_items
end
