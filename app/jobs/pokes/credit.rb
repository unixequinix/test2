class Pokes::Credit < Pokes::Base
  include PokesHelper

  FEES = %w[gtag_deposit_fee gtag_return_fee initial_fee refund_fee topup_fee].freeze
  CORRECTIONS = %w[gtag_balance_fix correction].freeze
  ACTIONS = %w[topup refund replacement_topup replacement_refund].freeze

  TRIGGERS = FEES + CORRECTIONS + ACTIONS

  queue_as :medium_low

  def perform(t) # rubocop:disable Metrics/PerceivedComplexity
    description = t.action
    description = t.action.gsub("_fee", "") if FEES.include?(t.action)
    description = "checkin" if t.station.category.eql?("check_in") && t.action.eql?("topup")
    description = "purchase" if t.station.category.eql?("box_office") && t.action.eql?("topup")

    action = "record_credit"
    action = "fee" if FEES.include?(t.action)
    action = "correction" if CORRECTIONS.include?(t.action)

    t.payments.to_a.map.with_index do |payment, i|
      credit_id, payment = payment
      atts = extract_credit_atts(credit_id, payment, action: action, description: description, line_counter: i + 1)
      create_poke(extract_atts(t, atts))
    end
  end
end
