class Stats::Money < Stats::Base
  include StatsHelper

  # MoneyTransaction#topup actually does not exist, since online topups are called purchases. But in case it happens
  TRIGGERS = %w[onsite_topup onsite_refund refund topup].freeze

  def perform(transaction_id)
    t = MoneyTransaction.find(transaction_id)
    create_stat(extract_atts(t, extract_money_atts(t)))
  end
end
