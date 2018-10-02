class Pokes::Credit < Pokes::Base
  include PokesHelper

  FEES = %w[gtag_deposit_fee gtag_return_fee initial_fee refund_fee topup_fee].freeze
  CORRECTIONS = %w[gtag_balance_fix correction].freeze
  ACTIONS = %w[record_credit topup refund replacement_topup replacement_refund].freeze

  TRIGGERS = FEES + CORRECTIONS + ACTIONS

  queue_as :low

  def perform(transaction)
    description = transaction.action
    description = transaction.action.gsub("_fee", "") if FEES.include?(transaction.action)
    description = "checkin" if transaction.station.category.eql?("check_in") && transaction.action.eql?("topup")
    description = "purchase" if transaction.station.category.eql?("box_office") && transaction.action.eql?("topup")

    action = "record_credit"
    action = "fee" if FEES.include?(transaction.action)
    action = "correction" if CORRECTIONS.include?(transaction.action)

    pokes = transaction.payments.to_a.map.with_index do |payment, i|
      credit_id, payment = payment
      atts = extract_credit_atts(credit_id, payment, action: action, description: description, line_counter: i + 1)
      create_poke(extract_atts(transaction, atts))
    end

    recalculate_balance(transaction)

    pokes
  end

  private

  def recalculate_balance(transaction)
    transaction.gtag&.recalculate_balance
    transaction.customer.update(initial_topup_fee_paid: true) if transaction.action.eql?("initial_fee")

    return unless transaction.customer_tag_uid == transaction.operator_tag_uid

    Alert.propagate(transaction.event, transaction, "has the same operator and customer UIDs", :medium)
  end
end
