class Pokes::Money < Pokes::Base
  include PokesHelper

  TRIGGERS = %w[onsite_topup onsite_refund online_refund].freeze
  NON_PAYMENTS = %w[other none].freeze

  def perform(transaction)
    return if transaction.payment_method.in?(NON_PAYMENTS) && transaction.action.eql?("onsite_topup")
    atts = { action: transaction.action.gsub("onsite_", "").gsub("online_", "") }
    create_poke(extract_atts(transaction, extract_money_atts(transaction, atts)))
  end
end
