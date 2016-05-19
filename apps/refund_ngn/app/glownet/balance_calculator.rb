class BalanceCalculator
  def initialize(profile)
    @profile = profile
  end

  def valid_balance?
    current_balance.nil? ||
      current_balance.final_balance == total_credits_amount &&
      current_balance.final_refundable_balance == total_refundable_credits_amount
  end

  def total_credits_amount
    customer_credits.sum(:amount)
  end

  def total_refundable_credits_amount
    customer_credits.sum(:refundable_amount)
  end

  def current_balance
    @profile.current_balance
  end

  def customer_credits
    @profile.customer_credits
  end
end
