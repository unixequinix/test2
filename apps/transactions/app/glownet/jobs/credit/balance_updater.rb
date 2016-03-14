class Jobs::Credit::BalanceUpdater < Jobs::Base
  SUBSCRIPTIONS = %w( sale topup refund fee sale_refund )

  def perform(atts)
    credit_atts = Jobs::Base.extract_attributes(CustomerCredit, atts)
    CustomerCredit.create!(credit_atts)
  end
end
