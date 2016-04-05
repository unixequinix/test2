class Management::RefundManager
  def self.refund_method_for(profile)
    return "direct" if profile.refundable_money_amount <= profile.online_refundable_money_amount
    "transfer"
  end

  def self.get_online_payments(profile)
    # array because we are going to delete and add and dont want to mess AR relations
    payments = profile.payments.where(success: true).sort_by { |p| p.amount.to_f }.reverse.to_a
    reduce_payments(payments, profile.refundable_money_amount)
  end

  def self.reduce_payments(payments, amount)
    payment = payments.shift
    return [] unless payment
    return [[payment, amount.to_f]] if payment.amount > amount
    [[payment, payment.amount.to_f]] + reduce_payments(payments, amount - payment.amount.to_f)
  end

  def self.execute(profile)
    return false unless refund_method_for(profile).eql?("direct")
    get_online_payments(profile).each do |payment, amount|
      "Payments::#{payment.payment_type.camelcase}Refunder".constantize.new(payment, amount).start
    end
  end
end
