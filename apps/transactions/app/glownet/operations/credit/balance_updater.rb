class Operations::Credit::BalanceUpdater < Operations::Base
  TRIGGERS = %w( sale topup refund fee sale_refund online_topup
                 auto_topup create_credit ticket_topup online_refund record_credit ).freeze

  def perform(atts)
    Profile.find(atts[:profile_id]).recalculate_balance
  end
end
