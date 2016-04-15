class Autotopup::PaypalNvpAgreement
  def self.create(token, customer_event_profile, autotopup_amount)
    customer_event_profile.payment_gateway_customers
      .find_or_create_by(gateway_type: EventDecorator::PAYPAL_NVP)
      .update(token: token,
              agreement_accepted: true,
              autotopup_amount: autotopup_amount)
    customer_event_profile.save
  end
end
