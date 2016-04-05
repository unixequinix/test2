class BalanceCalculator
  def initialize(customer_event_profile)
    @customer_event_profile = customer_event_profile
  end

  def valid_balance?
    current_balance.nil? ||
      current_balance.final_balance == total_credits_amount &&
      current_balance.final_refundable_balance == total_refundable_credits_amount
  end

  def total_credits_amount
    customer_credits.sum(:amount).floor
  end

  def total_refundable_credits_amount
    customer_credits.sum(:refundable_amount).floor
  end

  def current_balance
    @customer_event_profile.current_balance
  end

  def customer_credits
    @customer_event_profile.customer_credits
  end
end
