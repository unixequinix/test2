# == Schema Information
#
# Table name: credit_logs
#
#  id                        :integer          not null, primary key
#  transaction_type          :string
#  amount                    :decimal(8, 2)    not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  customer_event_profile_id :integer
#

class CreditLog < ActiveRecord::Base
  # Associations
  belongs_to :customer_event_profile

  TICKET_ASSIGNMENT  = "ticket_assignment"
  TICKET_UNASSIGNMENT  = "ticket_unassignment"
  CREDITS_PURCHASE  = "credits_purchase"

  # Type of the invoices
  TRANSACTION_TYPES = [TICKET_ASSIGNMENT, TICKET_UNASSIGNMENT, CREDITS_PURCHASE]

  # Validations
  validates :customer_event_profile, :transaction_type, :amount, presence: true
end
