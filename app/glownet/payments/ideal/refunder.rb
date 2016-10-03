class Payments::Ideal::Refunder < Payments::Wirecard::BaseRefunder
  def create_payment(order, charge)
    payment = super(order, charge)
    payment.payment_type = "ideal"
    payment.save
  end
end
