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
  GTAG_DEFINITIONS = [{ name: "mifare_classic", entitlement_limit: 15, credential_limit: 15 },
                      { name: "ultralight_ev1", entitlement_limit: 40, credential_limit: 32 },
                      { name: "ultralight_c", entitlement_limit: 56, credential_limit: 32 }].freeze

  # Associations
  belongs_to :event
  belongs_to :profile

  has_many :claims

  has_one :refund
  has_one :purchaser, as: :credentiable, dependent: :destroy
  has_one :completed_claim, -> { where(aasm_state: :completed) }, class_name: "Claim"

  accepts_nested_attributes_for :purchaser, allow_destroy: true

  # Callbacks
  before_validation :upcase_gtag!

  # Validations
  validates :tag_uid, uniqueness: { scope: [:event_id, :activation_counter] }
  validates :tag_uid, presence: true
  # TODO: enable when andriod stops sending fake uids (DEVICE, TAG)
  # validates :tag_uid, format: { with: /\A[0-9A-Fa-f]+\z/, message: I18n.t("errors.messages.only_hex") }

  # Scopes
  scope :query_for_csv, lambda  { |event|
    event.gtags.joins("LEFT OUTER JOIN customer_orders
                       ON customer_orders.profile_id = profile_id
                       AND customer_orders.deleted_at IS NULL")
         .select("gtags.id, gtags.tag_uid, gtags.banned, gtags.loyalty, gtags.format,
                        customer_orders.amount as credits_amount")
  }

  scope :banned, -> { where(banned: true) }

  alias_attribute :reference, :tag_uid

  def assigned?
    profile.present? && profile.customer.present?
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

  FORMATS.each do |method_name|
    define_method "#{method_name}?" do
      format == method_name
    end
  end

  def upcase_gtag!
    tag_uid.upcase! if tag_uid
  end
end
