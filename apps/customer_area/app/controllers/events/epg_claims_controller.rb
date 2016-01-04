class Events::EpgClaimsController < Events::ClaimsController
  def new
    @epg_claim_form = EpgClaimForm.new
    @claim = generate_claim
  end

  def create
    @epg_claim_form = EpgClaimForm.new(permitted_params)
    @claim = Claim.find(permitted_params[:claim_id])
    if @epg_claim_form.save
      flash[:notice] = I18n.t("alerts.created")
      @claim.start_claim!
      redirect_to EpgCheckout.new(@claim, @epg_claim_form).url
    else
      render :new
    end
  end

  private

  def permitted_params
    params.require(form_name).permit(:country_code, :state, :city,
                                           :post_code, :phone, :address, :claim_id, :agreed_on_claim)
  end

  def service_type
    Claim::EASY_PAYMENT_GATEWAY
  end

  def form_name
    "#{service_type}_claim_form"
  end
end
