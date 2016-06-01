class RefundService
  def initialize(claim)
    @claim = claim
    @profile = @claim.profile
  end

  def create(params)
    params = params.slice(*Refund.column_names.map(&:to_sym))
    refund = Refund.create!(params.merge(claim_id: @claim.id))
    status_ok = %w( SUCCESS PENDING ).include? refund.status
    return false unless status_ok
    @claim.complete!
    update_balance_after_refund(refund)
    ClaimMailer.completed_email(@claim, @profile.event).deliver_later
  end

  def update_balance_after_refund(refund)
    neg = (refund.amount * -1)
    params = {
      amount: neg, refundable_amount: neg, credit_value: @claim.event.standard_credit_price,
      payment_method: refund.payment_solution, transaction_origin: "refund",
      created_in_origin_at: Time.zone.now
    }
    customer_credits.create!(params)
  end

end
