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
#  device_db_index           :integer
#  customer_event_profile_id :integer
#  status_code               :string
#  status_message            :string
#  created_at                :datetime
#  updated_at                :datetime
#  device_uid                :string
#

class MonetaryTransaction < ActiveRecord::Base
  belongs_to :event
  belongs_to :station
  belongs_to :device
  belongs_to :customer_event_profile
  has_many :line_items
  has_many :transaction_sale_items

  validates_presence_of :transaction_type

  accepts_nested_attributes_for :transaction_sale_items
end
