module Payments::AutomaticRefundable
  def automatic_refund(payment, amount, payment_service)
    binding.pry
    payer = "Payments::#{payment_service.camelize}Refunder".constantize.new(payment, amount)
    payer.start
  end
end
