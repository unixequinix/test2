class Payments::Sofort::Refunder < Payments::Wirecard::BaseRefunder
  def create_payment(order, charge)
    payment = super(order, charge)
    payment.payment_type = "sofort"
    payment.save
  end
end
