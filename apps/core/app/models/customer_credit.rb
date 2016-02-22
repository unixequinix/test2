# == Schema Information
#
# Table name: customer_credits
#
#  id                        :integer          not null, primary key
#  customer_event_profile_id :integer          not null
#  amount                    :decimal(, )      not null
#  refundable_amount         :decimal(, )      not null
#  final_balance             :decimal(, )      not null
#  final_refundable_balance  :decimal(, )      not null
#  value_credit              :decimal(, )      not null
#  payment_method            :string           not null
#  transaction_source        :string           not null
#  deleted_at                :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class CustomerCredit < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :customer_event_profile

  validates_presence_of :payment_method, :transaction_source, :customer_event_profile
  validates_numericality_of :amount, :refundable_amount, :value_credit
  validates_numericality_of :final_balance, :final_refundable_balance, greater_than_or_equal_to: 0
end
