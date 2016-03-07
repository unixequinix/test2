class Jobs::Credit::BalanceUpdater < Jobs::Base
  TYPES = %w( sale topup refund fee sale_refund )

  def perform(atts)
    column_names = CustomerCredit.column_names
    credit_atts = atts.dup.keep_if { |k, _| column_names.include? k.to_s }
    CustomerCredit.create! credit_atts
  end
end
