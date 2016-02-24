# == Schema Information
#
# Table name: customer_credits
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

class CustomerCredit < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :customer_event_profile

  validates_presence_of :payment_method, :transaction_source, :customer_event_profile
  validates_numericality_of :amount, :refundable_amount, :value_credit
  validates_numericality_of :final_balance, :final_refundable_balance, greater_than_or_equal_to: 0

  TICKET_ASSIGNMENT  = "ticket_assignment"
  TICKET_UNASSIGNMENT  = "ticket_unassignment"
  CREDITS_PURCHASE  = "credits_purchase"

  # Type of the invoices
  TRANSACTION_TYPES = [TICKET_ASSIGNMENT, TICKET_UNASSIGNMENT, CREDITS_PURCHASE]
end
