class Events::TipaltiClaimsController < Events::ClaimsController
  def new
    @claim = generate_claim
    @url = TipaltiCheckout.new(@claim).url
    @claim.start_claim!
  end

  private

  def permitted_params
    params.require(:bank_account_claim_form).permit(:iban, :swift, :claim_id, :agreed_on_claim)
  end

  def service_type
    Claim::TIPALTI
  end
end
