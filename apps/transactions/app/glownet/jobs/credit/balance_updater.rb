class Jobs::Credit::BalanceUpdater < Jobs::Base
  TYPES = %w( sale topup refund fee sale_refund )

  def perform(_atts)
  end
end
