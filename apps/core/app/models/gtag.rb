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
                        entitlement_limit: 15,
                        credential_limit: 15 },
                      { name: "ultralight_ev1",
                        entitlement_limit: 40,
                        credential_limit: 32 },
                      { name: "ultralight_c",
                        entitlement_limit: 56,
                        credential_limit: 32 }
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
  has_one :assigned_profile,
          through: :assigned_gtag_credential,
          source: :profile
  has_many :profiles, through: :credential_assignments
  has_one :refund
  has_many :claims
  has_one :completed_claim, -> { where(aasm_state: :completed) }, class_name: "Claim"
  has_many :comments, as: :commentable
  has_many :credential_assignments, as: :credentiable, dependent: :destroy
  has_one :purchaser, as: :credentiable, dependent: :destroy
  belongs_to :company_ticket_type

  accepts_nested_attributes_for :purchaser, allow_destroy: true

  # Validations
  validates_uniqueness_of :tag_uid, scope: :event_id
  validates :tag_uid, presence: true

  # Scope
  scope :selected_data, lambda  { |event_id|
    joins("LEFT OUTER JOIN credential_assignments
           ON credential_assignments.credentiable_id = gtags.id
           AND credential_assignments.credentiable_type = 'Gtag'
           AND credential_assignments.deleted_at IS NULL
           LEFT OUTER JOIN customer_orders
           ON customer_orders.profile_id =
           credential_assignments.profile_id
           AND customer_orders.deleted_at IS NULL")
      .select("gtags.id, gtags.event_id, gtags.company_ticket_type_id, gtags.tag_serial_number,
               gtags.tag_uid, gtags.credential_redeemed, customer_orders.amount")
      .where(event: event_id)
  }

  scope :search_by_company_and_event, lambda { |company, event|
    includes(:purchaser, :company_ticket_type, company_ticket_type: [:company])
      .where(event: event, companies: { name: company })
  }

  def refundable_amount
    balance = assigned_profile.current_balance
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
    balance = assigned_profile.current_balance

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
