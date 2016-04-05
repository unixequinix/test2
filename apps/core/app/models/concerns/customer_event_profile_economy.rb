module CustomerEventProfileEconomy
  extend ActiveSupport::Concern
  def current_balance
    customer_credits.order(created_in_origin_at: :desc).first
  end

  def total_credits
    customer_credits.sum(:amount)
  end

  def ticket_credits
    customer_credits.where.not(transaction_origin: CustomerCredit::CREDITS_PURCHASE)
      .sum(:amount).floor
  end

  def purchased_credits
    customer_credits.where(transaction_origin: CustomerCredit::CREDITS_PURCHASE)
      .sum(:amount).floor
  end

  def refundable_credits_amount
    current_balance = customer_credits.current
    current_balance.present? ? current_balance.final_refundable_balance : 0
  end

  def refundable_money_amount
    customer_credits.reduce(0) do |total, customer_credit|
      total + customer_credit.credit_value * customer_credit.refundable_amount
    end
  end

  def online_refundable_money_amount
    payments.map(&:amount).sum
  end
end
