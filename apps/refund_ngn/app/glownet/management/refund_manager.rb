class Management::RefundManager
  def initialize(profile)
    @profile = profile
  end

  def execute
    return unless refund_method_for(@profile).eql?("direct")
    online_payments(@profile).map do |payment, amount|
      "Payments::#{payment.payment_type.camelcase}Refunder".constantize.new(payment, amount).start
    end
  end

  def online_payments
    # array because we are going to delete and add and dont want to mess AR relations
    payments = @profile.payments.where(success: true).sort_by { |p| p.amount.to_f }.reverse.to_a
    reduce_payments(payments, @profile.refundable_money_amount)
  end

  def reduce_payments(payments, amount)
    payment = payments.shift
    return [] unless payment
    return [[payment, amount.to_f]] if payment.amount > amount
    [[payment, payment.amount.to_f]] + reduce_payments(payments, amount - payment.amount.to_f)
  end
end
