class Operations::Credit::BalanceUpdater < Operations::Base
  TRIGGERS = %w( sale topup refund fee sale_refund online_topup
                 auto_topup create_credit ticket_topup online_refund ).freeze

  def perform(atts)
    profile = Profile.find(atts[:profile_id])
    atts[:refundable_credits] = atts[:credits_refundable]
    device_trans = profile.credit_transactions.status_ok.origin(:device)
    trans = profile.credit_transactions.status_ok.not_record_credit
    refundable_credits = trans.sum(:credits_refundable) + atts[:refundable_credits].to_f

    profile.update! credits: trans.sum(:credits) + atts[:credits].to_f,
                    refundable_credits: refundable_credits,
                    final_balance: device_trans.last&.final_balance,
                    final_refundable_balance: device_trans.last&.final_refundable_balance
  end
end
