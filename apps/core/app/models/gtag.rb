# == Schema Information
#
# Table name: gtags
#
#  id                     :integer          not null, primary key
#  event_id               :integer          not null
#  company_ticket_type_id :integer
#  tag_serial_number      :string
#  tag_uid                :string           not null
#  credential_redeemed    :boolean          default(FALSE), not null
#  deleted_at             :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class Gtag < ActiveRecord::Base
  STANDARD = "standard"
  CARD  = "card"
  SIMPLE = "simple"

  # Type of the gtags
  FORMATS = [STANDARD, CARD, SIMPLE]

  # Gtag limits
  GTAG_DEFINITIONS = [{ name: "mifare_classic",
                        entitlement_limit: 42,
                        shift: 1,
                        memory_length: "simple",
                        credential_limit: 34,},
                      { name: "ultralight_ev1",
                        entitlement_limit: 80,
                        shift: 2,
                        memory_length: "double",
                        credential_limit: 40,}
                     ]

  before_validation :upcase_gtag!
  default_scope { order(:id) }
  acts_as_paranoid

  # Associations
  belongs_to :event
  has_one :assigned_gtag_credential,
          -> { where(credential_assignments: { aasm_state: :assigned }) },
          as: :credentiable,
          class_name: "CredentialAssignment"
  has_one :assigned_customer_event_profile,
          through: :assigned_gtag_credential,
          source: :customer_event_profile
  has_many :customer_event_profiles, through: :credential_assignments
  has_one :refund
  has_many :claims
  has_one :completed_claim, -> { where(aasm_state: :completed) }, class_name: "Claim"
  has_many :comments, as: :commentable
  has_many :credential_assignments, as: :credentiable, dependent: :destroy
  has_one :purchaser, as: :credentiable, dependent: :destroy
  has_one :banned_gtag
  belongs_to :company_ticket_type

  accepts_nested_attributes_for :purchaser, allow_destroy: true

  # Validations
  validates_uniqueness_of :tag_uid, scope: :event_id
  validates :tag_uid, presence: true

  # Scope
  scope :selected_data, lambda  { |event_id|
    joins("LEFT OUTER JOIN gtag_credit_logs ON gtag_credit_logs.gtag_id = gtags.id")
      .select("gtags.*, gtag_credit_logs.amount")
      .where(event: event_id)
  }

  scope :search_by_company_and_event, lambda { |company, event|
    includes(:purchaser, :company_ticket_type, company_ticket_type: [:company])
      .where(event: event, companies: { name: company })
  }

  scope :banned, lambda {
    joins(:banned_gtag)
  }

  def ban!
    assignment = CredentialAssignment.find_by(credentiable_id: id, credentiable_type: "Gtag")
    BannedCustomerEventProfile.new(assign.customer_event_profile_id) unless assignment.nil?
    BannedGtag.create!(gtag_id: id)
  end

  def refundable_amount
    balance = assigned_customer_event_profile.current_balance
    standard_credit_price = event.standard_credit_price
    credit_amount = 0
    credit_amount = balance.refundable_amount if balance.present?
    credit_amount * standard_credit_price
  end

  def refundable_amount_after_fee(refund_service)
    fee = event.refund_fee(refund_service)
    refundable_amount - fee.to_f
  end

  def refundable?(refund_service)
    balance = assigned_customer_event_profile.current_balance

    minimum = event.refund_minimun(refund_service).to_f
    balance.present? &&
      (refundable_amount_after_fee(refund_service) >= minimum &&
      refundable_amount_after_fee(refund_service) >= 0)
  end

  def any_refundable_method?
    event.selected_refund_services.any? { |service| refundable?(service) }
  end

  def self.field_by_memory_length(memory_length:, field:)
    found = GTAG_DEFINITIONS.find do |definition|
      definition[:memory_length] == memory_length
    end
    return found[field.to_sym] if found
  end

  def self.field_by_name(name:, field:)
    found = GTAG_DEFINITIONS.find do |definition|
      definition[:name] == name
    end
    return found[field.to_sym] if found
  end

  private

  def upcase_gtag!
    tag_uid.upcase! if tag_uid
    tag_serial_number.upcase! if tag_serial_number
  end
end
