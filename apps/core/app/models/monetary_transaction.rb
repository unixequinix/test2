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
  acts_as_paranoid
  belongs_to :customer_event_profile

  validates_presence_of :payment_method, :transaction_source, :customer_event_profile
  validates_numericality_of :amount, :refundable_amount, :value_credit
  validates_numericality_of :final_balance, :final_refundable_balance, greater_than_or_equal_to: 0
end
