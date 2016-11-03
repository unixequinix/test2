class Management::RefundManager
  def initialize(profile, amount)
    @profile = profile
    @amount = amount
  end

  def execute
    online_payments.map do |payment, amount|
      klass = "Payments::#{payment.payment_type.camelcase}::Refunder".constantize
      klass.new(payment, amount).start
    end
  end

  def online_payments
    # .to_a because we are going to delete and add and dont want to mess AR relations
    payments = @profile.payments.where(success: true).sort_by { |p| p.amount.to_f }.reverse.to_a
    reduce_payments(payments, @amount)
  end

  def reduce_payments(payments, amount)
    payment = payments.shift
    return [] unless payment
    return [[payment, amount.to_f]] if payment.amount > amount
    [[payment, payment.amount.to_f]] + reduce_payments(payments, amount - payment.amount.to_f)
  end
end