class Payments::Wirecard::Refunder < Payments::Wirecard::BaseRefunder
  def create_payment(order, charge)
    payment = super(order, charge)
    payment.payment_type = "wirecard"
    payment.save
  end
end
