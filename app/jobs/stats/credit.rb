class Stats::Credit < Stats::Base
  include StatsHelper

  FEES = %w[gtag_deposit_fee gtag_return_fee initial_fee refund_fee topup_fee].freeze
  CORRECTIONS = %w[gtag_balance_fix correction].freeze
  ACTIONS = %w[record_credit topup refund replacement_topup replacement_refund].freeze

  TRIGGERS = FEES + CORRECTIONS + ACTIONS

  def perform(transaction_id) # rubocop:disable Metrics/PerceivedComplexity
    t = CreditTransaction.find(transaction_id)

    name = t.action
    name = t.action.gsub("_fee", "") if FEES.include?(t.action)
    name = "checkin" if t.station.category.eql?("check_in") && t.action.eql?("topup")
    name = "purchase" if t.station.category.eql?("box_office") && t.action.eql?("topup")

    action = "record_credit"
    action = "fee" if FEES.include?(t.action)
    action = "correction" if CORRECTIONS.include?(t.action)

    create_stat(extract_atts(t, extract_credit_atts(t.event.credit, credit_amount: t.credits, action: action, name: name)))
  end
end
