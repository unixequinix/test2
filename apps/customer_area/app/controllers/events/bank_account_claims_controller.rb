class Events::BankAccountClaimsController < Events::ClaimsController
  def new
    @bank_account_claim_form = ("#{area.camelize}BankAccountClaimForm").constantize.new
    @claim = generate_claim
  end

  def create
    @bank_account_claim_form = ("#{area.camelize}BankAccountClaimForm").constantize.new(permitted_params)
    @claim = Claim.find(permitted_params[:claim_id])
    if @bank_account_claim_form.save
      @claim.start_claim!
      # TODO: Remove hardcoded message text
      if RefundService.new(@claim, current_event)
         .create(amount: @claim.gtag.refundable_amount_after_fee(service_type),
                 currency: current_event.currency,
                 message: "Created manual bank account refund",
                 payment_solution: "manual",
                 status: "PENDING")
        redirect_to success_event_refunds_url(current_event)
      else
        redirect_to error_event_refunds_url(current_event)
      end
    else
      render :new
    end
  end

  private

  def permitted_params
    params.require(form_name).permit(:iban, :swift, :number, :bsb, :bank_name, :account_holder, :account_holder_translation, :claim_id, :event_id, :agreed_on_claim)
  end

  def service_type
    Claim::BANK_ACCOUNT
  end

  def form_name
    "#{area}_#{service_type}_claim_form"
  end

  def area
    current_event.get_parameter("refund", "bank_account", "area")
  end
end
