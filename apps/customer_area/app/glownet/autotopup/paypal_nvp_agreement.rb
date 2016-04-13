class Autotopup::PaypalNvpAgreement
  def self.create(token, customer_event_profile, autotopup_amount, agreement_accepted)
    PaymentGatewayCustomer.create(
      token: token,
      customer_event_profile: customer_event_profile,
      gateway_type: "paypal_nvp",
      agreement_accepted: agreement_accepted,
      autotopup_amount: autotopup_amount)
  end
end
