# == Schema Information
#
# Table name: customer_credits
#
#  id                       :integer          not null, primary key
#  profile_id               :integer          not null
#  transaction_origin       :string           not null
#  payment_method           :string           not null
#  amount                   :decimal(8, 2)    default(0.0), not null
#  refundable_amount        :decimal(8, 2)    default(0.0), not null
#  final_balance            :decimal(8, 2)    default(0.0), not null
#  final_refundable_balance :decimal(8, 2)    default(0.0), not null
#  credit_value             :decimal(8, 2)    default(1.0), not null
#  deleted_at               :datetime
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  created_in_origin_at     :datetime
#  gtag_counter             :integer
#  online_counter           :integer          default(0)
#

class CustomerCredit < ActiveRecord::Base
  default_scope { order(gtag_counter: :desc, online_counter: :desc) }
  acts_as_paranoid

  belongs_to :profile

  validates_presence_of :payment_method, :transaction_origin, :profile_id
  validates_numericality_of :amount, :refundable_amount, :credit_value

  TICKET_ASSIGNMENT = "ticket_assignment".freeze
  TICKET_UNASSIGNMENT = "ticket_unassignment".freeze
  CREDITS_PURCHASE = "credits_purchase".freeze

  # Type of the invoices
  TRANSACTION_TYPES = [TICKET_ASSIGNMENT, TICKET_UNASSIGNMENT, CREDITS_PURCHASE].freeze
end
