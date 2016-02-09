# == Schema Information
#
# Table name: gtags
#
#  id                     :integer          not null, primary key
#  tag_uid                :string           not null
#  tag_serial_number      :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  deleted_at             :datetime
#  event_id               :integer          not null
#  credential_redeemed    :boolean          default(FALSE), not null
#  company_ticket_type_id :integer
#

class Gtag < ActiveRecord::Base
  STANDARD = "standard"
  CARD  = "card"
  SIMPLE = "simple"

  # Type of the gtags
  FORMATS = [STANDARD, CARD, SIMPLE]

  before_validation :upcase_gtag!
  default_scope { order(:id) }
  acts_as_paranoid

  # Associations
  belongs_to :event
  has_one :assigned_gtag_credential, -> { where(aasm_state: :assigned) }, as: :credentiable, class_name: "CredentialAssignment"
  has_many :customer_event_profiles, through: :credential_assignments
  has_one :assigned_customer_event_profile, -> { where(credential_assignments: { aasm_state: :assigned }) }, class_name: "CredentialAssignment"
  has_one :gtag_credit_log
  has_one :refund
  has_many :claims
  has_one :completed_claim, -> { where(aasm_state: :completed) }, class_name: "Claim"
  has_many :comments, as: :commentable
  has_many :credential_assignments, as: :credentiable, dependent: :destroy
  has_many :purchasers, as: :credentiable, dependent: :destroy
  has_one :banned_gtag
  belongs_to :company_ticket_type

  accepts_nested_attributes_for :gtag_credit_log, allow_destroy: true

  # Validations
  validates_uniqueness_of :tag_uid, scope: :event_id
  validates :tag_uid, :tag_serial_number, presence: true

  # Scope
  scope :selected_data, lambda  { |event_id|
    joins("LEFT OUTER JOIN gtag_credit_logs ON gtag_credit_logs.gtag_id = gtags.id")
      .select("gtags.*, gtag_credit_logs.amount")
      .where(event: event_id)
  }

  scope :search_by_company_and_event, lambda { |company, event|
    includes(:company_ticket_type, company_ticket_type: [:company])
      .where(event: event, companies: { name: company })
  }

  scope :banned, lambda {
    joins(:banned_gtag)
  }

  def refundable_amount
    current_event = event
    standard_credit_price = current_event.standard_credit_price
    credit_amount = 0
    credit_amount = gtag_credit_log.amount unless gtag_credit_log.nil?
    credit_amount * standard_credit_price
  end

  def refundable_amount_after_fee(refund_service)
    current_event = event
    fee = current_event.refund_fee(refund_service)
    refundable_amount - fee.to_f
  end

  def refundable?(refund_service)
    current_event = event
    minimum = current_event.refund_minimun(refund_service)
    !gtag_credit_log.nil? && (refundable_amount_after_fee(refund_service) >= minimum.to_f && refundable_amount_after_fee(refund_service) >= 0)
  end

  def any_refundable_method?
    event.selected_refund_services.any? { |refund_service| refundable?(refund_service) }
  end

  private

  def upcase_gtag!
    tag_uid.upcase!
    tag_serial_number.upcase!
  end
end
