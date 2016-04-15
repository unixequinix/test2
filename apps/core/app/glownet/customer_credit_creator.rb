class CustomerCreditCreator
  def create_credit_for(profile, *params)
    atts = params.first
    atts[:refundable_amount] ||= atts[:amount]
    atts[:payment_method] ||= "none"
    credits = profile.reload.customer_credits
    final_balance = credits.sum(:final_balance) + atts[:amount]
    final_refundable_balance = credits.sum(:final_refundable_balance) + atts[:refundable_amount]

    profile.customer_credits.create!(
      transaction_origin: atts[:origin],
      payment_method: atts[:payment_method],
      credit_value: atts[:credit_value],
      amount: atts[:amount],
      refundable_amount: atts[:refundable_amount],
      final_balance: final_balance,
      final_refundable_balance: final_refundable_balance,
      created_in_origin_at: Time.zone.now
    )
  end
end
