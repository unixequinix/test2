class Operations::Credit::BalanceUpdater < Operations::Base
  TRIGGERS = %w( sale topup refund fee sale_refund )

  def perform(atts)
    credit_atts = Operations::Base.extract_attributes(CustomerCredit, atts)
    # TODO: there is a before filter in CustomerCredit that overrides this, rmeove at some point.
    credit_atts.merge!(payment_method: "credits", created_in_origin_at: atts[:device_created_at])
    CustomerCredit.create!(credit_atts)
  end
end
