class Pokes::Money < Pokes::Base
  include PokesHelper

  # MoneyTransaction#topup actually does not exist, since online topups are called purchases. But in case it happens
  TRIGGERS = %w[onsite_topup onsite_refund online_refund].freeze

  def perform(transaction)
    atts = { action: transaction.action.gsub("onsite_", "").gsub("online_", "") }
    create_poke(extract_atts(transaction, extract_money_atts(transaction, atts)))
  end
end
