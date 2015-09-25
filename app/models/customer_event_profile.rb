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
  has_many :admissions, dependent: :destroy
  has_many :assigned_admissions, -> { where(aasm_state: :assigned) },
    class_name: 'Admission'
  has_many :gtag_registrations, dependent: :destroy
  has_one :assigned_gtag_registration, ->{ where(aasm_state: :assigned) },
    class_name: 'GtagRegistration'
  has_many :orders
  has_many :claims
  has_many :refunds, through: :claims
  has_many :credit_logs
  has_many :credit_purchased_logs, ->{ where(transaction_type: CreditLog::CREDITS_PURCHASE) },
    class_name: 'CreditLog'
  has_one :completed_claim, ->{ where(aasm_state: :completed) }, class_name: "Claim"

  # Validations
  validates :customer, :event, presence: true

  # Scopes
  scope :for_event, -> (event) { where(event: event) }

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
    self.assigned_gtag_registration.gtag.gtag_credit_log.amount unless self.assigned_gtag_registration.nil? || self.assigned_gtag_registration.gtag.gtag_credit_log.nil?
  end
end
