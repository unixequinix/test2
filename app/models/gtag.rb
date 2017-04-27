class Gtag < ActiveRecord::Base
  include Credentiable

  # Gtag limits
  DEFINITIONS = { mifare_classic: { entitlement_limit: 15, credential_limit: 15 },
                  ultralight_ev1: { entitlement_limit: 40, credential_limit: 32 },
                  ultralight_c:   { entitlement_limit: 56, credential_limit: 32 } }.freeze

  validates :tag_uid, uniqueness: { scope: :event_id }
  validates :tag_uid, presence: true
  validates :tag_uid, format: { with: /\A[a-zA-Z0-9]+\z/, message: I18n.t("alerts.only_letters_end_numbers") }

  scope(:query_for_csv, ->(event) { event.gtags.select("id, tag_uid, banned, format") })
  scope(:banned, -> { where(banned: true) })

  alias_attribute :reference, :tag_uid

  def recalculate_balance
    ts = transactions.onsite.credit.where(status_code: 0).order(:gtag_counter, :device_created_at)
    self.credits = ts.sum(:credits)
    self.refundable_credits = ts.sum(:refundable_credits)
    self.final_balance = ts.last&.final_balance.to_f
    self.final_refundable_balance = ts.last&.final_refundable_balance.to_f

    save if changed?
  end

  def solve_inconsistent
    ts = transactions.credit.order(gtag_counter: :asc).select { |t| t.status_code.zero? }
    transaction = transactions.credit.find_by(gtag_counter: 0)
    atts = assignation_atts.merge(gtag_counter: 0, gtag_id: id, final_balance: 0, final_refundable_balance: 0)
    transaction = CreditTransaction.write!(event, "correction", :device, nil, nil, atts) unless transaction

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
end
