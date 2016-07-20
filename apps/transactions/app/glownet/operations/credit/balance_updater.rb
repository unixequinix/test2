class Operations::Credit::BalanceUpdater < Operations::Base
  TRIGGERS = %w( sale topup refund fee sale_refund online_topup
                 auto_topup create_credit ticket_topup online_refund ).freeze

  def perform(atts)
    profile = Profile.find(atts[:profile_id])
    onsite_trans = profile.credit_transactions.status_ok.not_record_credit
    profile.update! credits: profile.credits + atts[:credits].to_f,
                    refundable_credits: profile.refundable_credits + atts[:refundable_credits].to_f,
                    final_balance: onsite_trans.last&.final_balance,
                    final_refundable_balance: onsite_trans.last&.final_refundable_balance
  end
end
