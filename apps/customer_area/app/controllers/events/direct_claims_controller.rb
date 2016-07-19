class Events::DirectClaimsController < Events::ClaimsController
  def new
    @direct_claim_form = DirectClaimForm.new
    @claim = generate_claim
  end

  def create
    @direct_claim_form = DirectClaimForm.new
    @claim = Claim.find(permitted_params[:claim_id])
    @claim.start_claim!
    # TODO: This block always runs since RefundManager returns an array. Fix with error handling
    #       from refunders
    refundable = current_profile.refundable_money
    if Management::RefundManager.new(current_profile, refundable).execute
      RefundService.new(@claim).create(amount: current_profile.refundable_money,
                                       currency: current_event.currency,
                                       message: "Created direct refund",
                                       payment_solution: "direct",
                                       status: "SUCCESS")
      redirect_to(success_event_refunds_url(current_event)) && return
    end

    redirect_to error_event_refunds_url(current_event)
  end

  private

  def permitted_params
    params.require(form_name).permit(:claim_id, :event_id, :agreed_on_claim)
  end

  def service_type
    Claim::DIRECT
  end

  def form_name
    "direct_claim_form"
  end
end
