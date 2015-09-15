class RefundService

  def initialize(claim, event)
    @claim = claim
    @event = event
  end

  def create(params)
    refund = Refund.new(claim_id: @claim.id,
      amount: params[:amount],
      currency: params[:currency],
      message: params[:message],
      operation_type: params[:operation_type],
      gateway_transaction_number: params[:gateway_transaction_number],
      payment_solution: params[:payment_solution],
      status: params[:status])
    refund.save!
    if refund.status == 'SUCCESS' || refund.status == 'PENDING'
      @claim.complete!
      send_mail_for(@claim)
    end
  end

  private

  def send_mail_for(claim)
    ClaimMailer.completed_email(@claim, @event).deliver_later
  end

end
