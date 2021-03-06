class Gtag < ApplicationRecord
  include Credentiable
  include Alertable
  include Eventable

  belongs_to :ticket_type, optional: true

  has_many :pokes, class_name: "Poke", foreign_key: "customer_gtag_id", dependent: :restrict_with_error, inverse_of: :customer_gtag
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

  scope :query_for_csv, (->(event, operator) { event.gtags.where(operator: operator).select(%i[id tag_uid banned credits virtual_credits final_balance final_virtual_balance]) })
  scope :inconsistent, (-> { where(consistent: false) })
  scope :missing_transactions, (-> { where(missing_transactions: true) })

  alias_attribute :reference, :tag_uid

  def name
    "Gtag: #{tag_uid}"
  end

  def self.policy_class
    AdmissionPolicy
  end

  def replace!(new_gtag)
    return if Customer.claim(event, customer, new_gtag.customer).nil?

    update!(banned: true, active: false)
    new_gtag.update!(active: true, customer: customer, operator: operator?)
  end

  def make_active!
    customer&.gtags&.where&.not(id: id)&.update_all(active: false)
    update!(active: true)
  end

  def recalculate_all
    recalculate_balance
    validate_missing_counters
  end

  def recalculate_balance
    pks = pokes.is_ok.order(:gtag_counter, :date)
    credit_pokes = pks.where(credit: event.credit)
    virtual_credit_pokes = pks.where(credit: event.virtual_credit)
    tokens_pokes = pks.where(credit_id: event.tokens.pluck(:id))
    tokens_credits = pokes.is_ok.where(credit_id: event.tokens.pluck(:id)).select(:credit_id).distinct.pluck(:credit_id)

    self.credits = credit_pokes.sum(:credit_amount)
    self.virtual_credits = virtual_credit_pokes.sum(:credit_amount)
    self.tokens = tokens_credits.map { |token_id| [token_id, tokens_pokes.where(credit_id: token_id).sum(:credit_amount).to_f] }.compact.to_h if event.tokens.any?

    self.final_balance = credit_pokes.last.final_balance.to_f if credit_pokes.last
    self.final_virtual_balance = virtual_credit_pokes.last.final_balance.to_f if virtual_credit_pokes.last
    self.final_tokens_balance = tokens_credits.map { |token_id| [token_id, tokens_pokes.where(credit_id: token_id).last.final_balance.to_f] }.to_h if tokens_pokes.last && event.tokens.any?

    Alert.propagate(event, self, "has negative balance") if final_balance.negative? || final_virtual_balance.negative? || final_tokens_balance.map { |_k, v| v if v&.negative? }.any?

    save! if changed?
  end

  def validate_missing_counters
    self.complete = missing_counters.empty?
    self.consistent = valid_balance?

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
