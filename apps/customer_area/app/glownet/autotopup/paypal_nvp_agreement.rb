class Autotopup::PaypalNvpAgreement
  def self.create(token, profile, autotopup_amount)
    profile.payment_gateway_customers
      .find_or_create_by(gateway_type: EventDecorator::PAYPAL_NVP)
      .update(token: token,
              agreement_accepted: true,
              autotopup_amount: autotopup_amount)
    profile.save
  end
end
