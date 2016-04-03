class Management::RefundManager
  def self.check(profile, refund_balance)
    return "online" if refund_balance.to_f <= profile.online_refundable_money_amount
    "offline"
  end

  def self.get_online_payments(profile, amount)
    # array because we are going to delete and add and dont want to mess AR relations
    payments = profile.payments.where(success: true).sort_by { |p| p.amount.to_f }.reverse.to_a
    reduce_payments(payments, amount)
  end

  def self.reduce_payments(payments, amount)
    payment = payments.shift
    return [[payment, amount.to_f]] if payment.amount > amount
    [[payment, payment.amount.to_f]] + reduce_payments(payments, amount - payment.amount.to_f)
  end

  def self.execute_payment(arr)
    arr.each { |p, amount| "#{p.payment_type}Refunder".constantize.new(p, amount).start }
  end
end
