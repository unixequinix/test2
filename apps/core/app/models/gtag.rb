# == Schema Information
#
# Table name: gtags
#
#  id                     :integer          not null, primary key
#  event_id               :integer          not null
#  company_ticket_type_id :integer
#  tag_uid                :string           not null
#  credential_redeemed    :boolean          default(FALSE), not null
#  deleted_at             :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  banned                 :boolean          default(FALSE)
#  format                 :string           default("wristband")
#

class Gtag < ActiveRecord::Base
  acts_as_paranoid
  default_scope { order(:id) }

  STANDARD = "standard".freeze
  CARD = "card".freeze
  SIMPLE = "simple".freeze
  WRISTBAND = "wristband".freeze

  # UID categorization of the gtags
  UID_FORMATS = [STANDARD, CARD, SIMPLE].freeze

  # Physical type of the gtags
  FORMATS = [CARD, WRISTBAND].freeze

  # Gtag limits
  GTAG_DEFINITIONS = [{ name: "mifare_classic",
                        entitlement_limit: 15,
                        credential_limit: 15 },
                      { name: "ultralight_ev1",
                        entitlement_limit: 40,
                        credential_limit: 32 },
                      { name: "ultralight_c",
                        entitlement_limit: 56,
                        credential_limit: 32 }].freeze

  # Associations
  belongs_to :event
  belongs_to :company_ticket_type

  has_many :claims
  has_many :comments, as: :commentable
  has_many :credential_assignments, as: :credentiable, dependent: :destroy
  has_many :profiles, through: :credential_assignments

  has_one :refund
  has_one :purchaser, as: :credentiable, dependent: :destroy
  has_one :completed_claim, -> { where(aasm_state: :completed) }, class_name: "Claim"
  has_one :assigned_profile, through: :assigned_gtag_credential, source: :profile
  has_one :assigned_gtag_credential,
          -> { where(credential_assignments: { aasm_state: :assigned }) },
          as: :credentiable,
          class_name: "CredentialAssignment"

  accepts_nested_attributes_for :purchaser, allow_destroy: true

  # Callbacks
  before_validation :upcase_gtag!

  # Validations
  validates_uniqueness_of :tag_uid, scope: :event_id
  validates :tag_uid, presence: true

  # Scopes
  scope :selected_data, lambda  { |event_id|
    joins("LEFT OUTER JOIN credential_assignments
           ON credential_assignments.credentiable_id = gtags.id
           AND credential_assignments.credentiable_type = 'Gtag'
           AND credential_assignments.deleted_at IS NULL
           LEFT OUTER JOIN customer_orders
           ON customer_orders.profile_id = credential_assignments.profile_id
           AND customer_orders.deleted_at IS NULL")
      .select("gtags.id, gtags.event_id, gtags.company_ticket_type_id, gtags.tag_uid,
               gtags.credential_redeemed, customer_orders.amount")
      .where(event: event_id)
  }

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

  FORMATS.each do |method_name|
    define_method "#{method_name}?" do
      format == method_name
    end
  end

  def upcase_gtag!
    tag_uid.upcase! if tag_uid
  end
end
