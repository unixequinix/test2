# == Schema Information
#
# Table name: customer_event_profiles
#
#  id          :integer          not null, primary key
#  customer_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  event_id    :integer          not null
#  deleted_at  :datetime
#

class CustomerEventProfile < ActiveRecord::Base
  acts_as_paranoid
  default_scope { order(created_at: :desc) }

  # Associations
  belongs_to :customer
  belongs_to :event
  has_many :orders
  has_many :claims
  has_many :refunds, through: :claims
  has_many :credit_logs
  has_many :credit_purchased_logs,
           -> { where(transaction_type: CreditLog::CREDITS_PURCHASE) },
           class_name: 'CreditLog'
  has_many :credential_assignments

  # credential_assignments_tickets
  has_many :ticket_assignments,
           -> { where(credentiable_type: 'Ticket') },
           class_name: 'CredentialAssignment', dependent: :destroy

  # credential_assignments_gtags
  has_many :gtag_assignment,
           -> { where(credentiable_type: 'Gtag') },
           class_name: 'CredentialAssignment', dependent: :destroy

  # credential_assignments_assigned
  has_many :active_assignments,
           -> { where(aasm_state: :assigned) }, class_name: 'CredentialAssignment'

  # credential_assignments_tickets_assigned
  has_many :active_tickets_assignment,
           -> { where(aasm_state: :assigned, credentiable_type: 'Ticket') },
           class_name: 'CredentialAssignment'

  # credential_assignments_gtag_assigned
  has_one :active_gtag_assignment,
          -> { where(aasm_state: :assigned, credentiable_type: 'Gtag') },
          class_name: 'CredentialAssignment'

  has_one :completed_claim,
          -> { where(aasm_state: :completed) }, class_name: 'Claim'

  # Validations
  validates :customer, :event, presence: true

  # Scopes
  scope :for_event, -> (event) { where(event: event) }
  scope :with_gtag, -> (event) { joins(:gtag_registrations).where(event: event, gtag_registrations: { aasm_state: :assigned }) }


  def customer
    Customer.unscoped { super }
  end

  def total_credits
    credit_logs.sum(:amount).floor
  end

  def ticket_credits
    credit_logs.where.not(transaction_type: CreditLog::CREDITS_PURCHASE).sum(:amount).floor
  end

  def purchased_credits
    credit_logs.where(transaction_type: CreditLog::CREDITS_PURCHASE).sum(:amount).floor
  end

  def refundable_credits
    assigned_gtag_registration.gtag.gtag_credit_log.amount unless assigned_gtag_registration.nil? || assigned_gtag_registration.gtag.gtag_credit_log.nil?
  end
end
