class Jobs::Credit::BalanceUpdater < Jobs::Base
  SUBSCRIPTIONS = %w( sale topup refund fee sale_refund )

  def perform(atts)
    CustomerCredit.create!(Jobs::Base.extract_attributes(CustomerCredit, atts))
  end
end
