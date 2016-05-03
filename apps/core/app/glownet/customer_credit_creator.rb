class CustomerCreditCreator
  def create_credit(profile, *params) # rubocop:disable Metrics/MethodLength
    atts = params.first
    atts[:refundable_amount] ||= atts[:amount]
    atts[:payment_method] ||= "none"
    credits = profile.reload.customer_credits
    final_balance = credits.sum(:amount) + atts[:amount]
    final_refundable_balance = credits.sum(:refundable_amount) + atts[:refundable_amount]

    profile.customer_credits.create(
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

  # TODO: check refundable flow and what is being showed and what actions are allowed
  # =>    depending on event state
  def calculate_finals(params, credits, amount, refundable_amount)
    params[:final_balance] = credits.sum(:amount) + amount
    params[:final_refundable_balance] = credits.sum(:refundable_amount) + refundable_amount
    params[:created_in_origin_at] = Time.zone.now
  end
end
