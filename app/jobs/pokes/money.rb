class Pokes::Money < Pokes::Base
  include PokesHelper

  # MoneyTransaction#topup actually does not exist, since online topups are called purchases. But in case it happens
  TRIGGERS = %w[onsite_topup onsite_refund online_refund].freeze

  def perform(t)
    atts = { action: t.action.gsub("onsite_", "").gsub("online_", "") }
    create_poke(extract_atts(t, extract_money_atts(t, atts)))
  end
end
