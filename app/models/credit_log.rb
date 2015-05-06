# == Schema Information
#
# Table name: credit_logs
#
#  id               :integer          not null, primary key
#  customer_id      :integer          not null
#  transaction_type :string
#  amount           :decimal(8, 2)    not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class CreditLog < ActiveRecord::Base

  # Associations
  belongs_to :customer

  TICKET_ASSIGMENT  = 'ticket_assignment'
  TICKET_UNASSIGMENT  = 'ticket_unassignment'
  CREDITS_PURCHASE  = 'credits_purchase'

  # Type of the invoices
  TRANSACTION_TYPES = [TICKET_ASSIGMENT, TICKET_UNASSIGMENT, CREDITS_PURCHASE]

  # Validations
  validates :customer, :transaction_type, :amount, presence: true
end
