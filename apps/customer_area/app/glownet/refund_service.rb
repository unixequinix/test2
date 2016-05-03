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
    @profile.update_balance_after_refund(refund)
    ClaimMailer.completed_email(@claim, @profile.event).deliver_later
  end
end
