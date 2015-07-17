class Customers::EpgClaimsController < Customers::ClaimsController

  def new
    @epg_claim_form = EpgClaimForm.new
    @claim = Claim.new
    @claim.service_type = Claim::EASY_PAYMENT_GATEWAY
    @claim.fee = EventParameter.find_by(event_id: current_event.id, parameter_id: Parameter.find_by(category: 'refund', group: current_event.refund_service, name: 'fee')).value
    @claim.customer = current_customer
    @claim.gtag = current_customer.assigned_gtag_registration.gtag
    @claim.total = current_customer.assigned_gtag_registration.gtag.gtag_credit_log.amount
    @claim.generate_claim_number!
    @claim.save!
  end

  def create
    @epg_claim_form = EpgClaimForm.new(permitted_params)
    @claim = Claim.find(permitted_params[:claim_id])
    if @epg_claim_form.save
      flash[:notice] = I18n.t('alerts.created')
      @claim.start_claim!
      redirect_to EpgCheckoutService.new(@claim, @epg_claim_form).url
    else
      render :new
    end
  end

  private

  def permitted_params
    params.require(:epg_claim_form).permit(:country_code, :state, :city, :post_code, :phone, :address, :claim_id, :agreed_on_claim)
  end

end