class RefundService
  def initialize(claim)
    @claim = claim
    @event = @claim.customer_event_profile.event
  end

  def create(params)
    refund = Refund.new(claim_id: @claim.id, amount: params[:amount], currency: params[:currency],
                        message: params[:message], operation_type: params[:operation_type],
                        gateway_transaction_number: params[:gateway_transaction_number],
                        payment_solution: params[:payment_solution], status: params[:status])
    refund.save!
    valid_status?(refund) ? complete_claim : false
  end

  private

  def valid_status?(ref)
    ref.status == "SUCCESS" || ref.status == "PENDING"
  end

  def complete_claim
    @claim.complete!
    send_mail_for(@claim)
  end

  def send_mail_for(_claim)
    ClaimMailer.completed_email(@claim, @event).deliver_later
  end
end
