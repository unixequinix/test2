class Operations::Credit::BalanceUpdater < Operations::Base
  TRIGGERS = %w( sale topup refund fee sale_refund online_topup
                 auto_topup create_credit ticket_topup online_refund ).freeze

  def perform(atts)
    profile = Profile.find(atts[:profile_id])
    atts[:refundable_credits] = atts[:credits_refundable]
    device_trans = profile.credit_transactions.status_ok.not_record_credit

    # TODO: Too many queries? Maybe remove these two columns? Simplify in a single query with the select method
    profile.update! credits: profile.credits + atts[:credits].to_f,
                    refundable_credits: profile.refundable_credits + atts[:refundable_credits].to_f,
                    final_balance: device_trans.last&.final_balance,
                    final_refundable_balance: device_trans.last&.final_refundable_balance
  end
end
