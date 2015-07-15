class Customers::BankAccountClaimsController < Customers::ClaimsController

  def new
    @bank_account_claim_form = BankAccountClaimForm.new
    @claim = Claim.new
    @claim.service_type = Claim::BANK_ACCOUNT
    @claim.fee = 2.0
    @claim.customer = current_customer
    @claim.gtag = current_customer.assigned_gtag_registration.gtag
    @claim.total = current_customer.assigned_gtag_registration.gtag.gtag_credit_log.amount
    @claim.generate_claim_number!
    @claim.save!
  end

  def create
    @bank_account_claim_form = BankAccountClaimForm.new(permitted_params)
    @claim = Claim.find(permitted_params[:claim_id])
    if @bank_account_claim_form.save
      @claim.start_claim!
      if RefundService.new(@claim, current_event).create(params = {
          amount: @claim.total_after_fee,
          currency: 'EUR',
          message: 'Created manual bank account refund',
          payment_solution: 'manual',
          status: 'PENDING'
        })
        redirect_to success_customers_refunds_url
      else
        redirect_to error_customers_refunds_url
      end
    else
      render :new
    end
  end

  private

  def permitted_params
    params.require(:bank_account_claim_form).permit(:iban, :swift, :claim_id, :agreed_on_claim)
  end

end