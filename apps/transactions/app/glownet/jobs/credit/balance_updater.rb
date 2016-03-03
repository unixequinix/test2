class Jobs::Credit::BalanceUpdater < Jobs::Base
  TYPES = %w( sale topup refund )

  def perform(_atts)
  end
end
