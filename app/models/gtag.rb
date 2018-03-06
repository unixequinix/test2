class Gtag < ApplicationRecord
  include Credentiable
  include Alertable
  include Eventable

  belongs_to :ticket_type, optional: true

  has_many :pokes_as_customer, class_name: "Poke", foreign_key: "customer_gtag_id", dependent: :restrict_with_error, inverse_of: :customer_gtag
  has_many :pokes_as_operator, class_name: "Poke", foreign_key: "operator_gtag_id", dependent: :restrict_with_error, inverse_of: :operator_gtag

  has_many :transactions, dependent: :restrict_with_error
  has_many :transactions_as_operator, class_name: "Transaction", foreign_key: "operator_gtag_id", dependent: :restrict_with_error, inverse_of: :operator_gtag

  before_save :upcase_tag_uid

  # Gtag limits
  DEFINITIONS = { ultralight_c:   { entitlement_limit: 56, credential_limit: 32 } }.freeze

  validates :tag_uid, uniqueness: { scope: :event_id },
                      presence: true,
                      format: { with: /\A[a-zA-Z0-9]+\z/, message: I18n.t("alerts.only_letters_and_numbers") },
                      length: { in: 8..14 }

  validates :format, presence: true
  validates :credits, :virtual_credits, :final_balance, :final_virtual_balance, presence: true, numericality: true

  validate_associations

  scope :query_for_csv, (->(event) { event.gtags.select(%i[id tag_uid banned credits virtual_credits final_balance final_virtual_balance]) })
  scope :banned, (-> { where(banned: true) })
  scope :inconsistent, (-> { where(inconsistent: true) })
  scope :missing_transactions, (-> { where(missing_transactions: true) })

  alias_attribute :reference, :tag_uid
  alias pokes pokes_as_customer

  def name
    "Gtag: #{tag_uid}"
  end

  def replace!(new_gtag)
    return if Customer.claim(event, customer, new_gtag.customer).nil?

    update!(banned: true, active: false)
    new_gtag.update!(active: true, customer: customer)
  end

  def make_active!
    customer&.gtags&.where&.not(id: id)&.update_all(active: false)
    update!(active: true)
  end

  def recalculate_balance # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity
    ts = transactions.onsite.status_ok.credit.order(:gtag_counter, :device_created_at)
    counters = transactions.onsite.order(:gtag_counter, :device_created_at).pluck(:gtag_counter).compact.sort
    payments = ts.payments_with_credit(event.credit)
    virtual_payments = ts.payments_with_credit(event.virtual_credit)

    if payments.present? || virtual_payments.present?
      last = payments.last
      virtual_last = virtual_payments.last

      self.credits = payments.sum { |t| t.payments[event.credit.id.to_s]["amount"].to_f }
      self.virtual_credits = virtual_payments.sum { |t| t.payments[event.virtual_credit.id.to_s]["amount"].to_f }
      self.final_balance = last.payments[event.credit.id.to_s]["final_balance"].to_f if last
      self.final_virtual_balance = virtual_last.payments[event.virtual_credit.id.to_s]["final_balance"].to_f if virtual_last
    else
      self.credits = ts.sum(:refundable_credits)
      self.virtual_credits = ts.sum(:credits) - ts.sum(:refundable_credits)
      self.final_balance = ts.last&.final_refundable_balance.to_f
      self.final_virtual_balance = ts.last&.final_balance.to_f - ts.last&.final_refundable_balance.to_f
    end

    self.consistent = valid_balance?
    self.complete = ((1..counters.last).to_a - counters).empty? if counters.any?

    Alert.propagate(event, self, "has negative balance") if final_balance.negative? || final_virtual_balance.negative?

    save! if changed?
  end

  def missing_counters
    counters = transactions.pluck(:gtag_counter).compact.sort
    (1..counters.last.to_i).to_a - counters
  end

  def valid_balance?
    credits == final_balance && virtual_credits == final_virtual_balance
  end

  def assigned?
    customer.present?
  end

  def assignation_atts
    { customer_tag_uid: tag_uid }
  end

  private

  def upcase_tag_uid
    self.tag_uid = tag_uid.upcase
  end
end
