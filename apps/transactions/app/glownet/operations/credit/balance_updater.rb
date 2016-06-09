class Operations::Credit::BalanceUpdater < Operations::Base
  TRIGGERS = %w( sale topup refund fee sale_refund online_topup
                 auto_topup create_credit ticket_topup online_refund ).freeze

  def perform(atts)
    profile = Profile.find(atts[:profile_id])
    device_trans = profile.credit_transactions.status_ok.origin(:device)
    trans = profile.credit_transactions.status_ok.not_record_credit
    profile.update! credits: trans.sum(:credits) + atts[:credits].to_f,
                    refundable_credits: trans.sum(:credits_refundable) + atts[:credits_refundable],
                    final_balance: device_trans.last&.final_balance,
                    final_refundable_balance: device_trans.last&.final_refundable_balance
  end
end
