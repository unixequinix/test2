class Gtag < ApplicationRecord
  include Credentiable
  include Alertable
  include Eventable
  belongs_to :ticket_type, optional: true

  before_save :upcase_tag_uid

  # Gtag limits
  DEFINITIONS = { ultralight_c:   { entitlement_limit: 56, credential_limit: 32 } }.freeze

  validates :tag_uid, uniqueness: { scope: :event_id },
                      presence: true,
                      format: { with: /\A[a-zA-Z0-9]+\z/, message: I18n.t("alerts.only_letters_and_numbers") },
                      length: { in: 8..14 }

  validates :format, presence: true
  validates :credits, :refundable_credits, :final_balance, :final_refundable_balance, presence: true, numericality: true

  validate_associations

  scope :query_for_csv, (->(event) { event.gtags.select(%i[id tag_uid banned credits refundable_credits final_balance final_refundable_balance]) })
  scope :banned, (-> { where(banned: true) })

  alias_attribute :reference, :tag_uid

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

  def recalculate_balance
    ts = transactions.onsite.credit.where(status_code: 0).order(:gtag_counter, :device_created_at)
    self.credits = ts.sum(:credits)
    self.refundable_credits = ts.sum(:refundable_credits)
    self.final_balance = ts.last&.final_balance.to_f
    self.final_refundable_balance = ts.last&.final_refundable_balance.to_f

    Alert.propagate(event, self, "has negative balance") if final_balance.negative? || final_refundable_balance.negative?

    save if changed?
  end

  def solve_inconsistent
    ts = transactions.credit.order(gtag_counter: :asc).select { |t| t.status_code.zero? }
    transaction = transactions.credit.find_by(gtag_counter: 0)
    atts = assignation_atts.merge(gtag_counter: 0, gtag_id: id, final_balance: 0, final_refundable_balance: 0)
    transaction ||= CreditTransaction.write!(event, "correction", :device, nil, nil, atts)

    credits = ts.last&.final_balance.to_f - ts.map(&:credits).sum
    refundable_credits = ts.last&.final_refundable_balance.to_f - ts.map(&:refundable_credits).sum

    transaction.update! credits: credits, refundable_credits: refundable_credits
    recalculate_balance
    transaction
  end

  def refundable_money
    refundable_credits.to_i * event.credit.value
  end

  def valid_balance?
    credits == final_balance && refundable_credits == final_refundable_balance
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
