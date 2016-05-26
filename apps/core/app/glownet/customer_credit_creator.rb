class CustomerCreditCreator
  def create_credit(profile, *params) # rubocop:disable Metrics/MethodLength
    atts = params.first
    atts[:payment_method] ||= "none"
    atts[:transaction_type] ||= "create_credit"
    credits = profile.reload.customer_credits
    final_balance = credits.sum(:amount) + atts[:amount].to_f
    final_refundable_balance = credits.sum(:refundable_amount) + atts[:refundable_amount].to_f

    fields = {
      transaction_category: "credit",
      transaction_type: atts[:transaction_type],
      event_id: profile.event.id,
      credits: atts[:amount].to_f,
      credits_refundable: atts[:refundable_amount].to_f,
      final_balance: final_balance.to_f,
      final_refundable_balance: final_refundable_balance.to_f,
      credit_value: atts[:credit_value].to_f,
      profile_id: profile.id,
      payment_method: atts[:payment_method]
    }

    Operations::Base.new.portal_write(fields)
  end
end
