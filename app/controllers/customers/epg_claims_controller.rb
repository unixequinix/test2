class Customers::EpgClaimsController < Customers::BaseController
  before_action :check_has_gtag!
  before_action :check_has_not_claims!
  before_action :require_permission!, only: [:create]

  def new
    @epg_claim_form = EpgClaimForm.new
    @claim = Claim.new
    @claim.service_type = Claim::EASY_PAYMENT_GATEWAY
    @claim.fee = 6.0
    @claim.generate_claim_number!
    @claim.customer = current_customer
    @claim.gtag = current_customer.assigned_gtag_registration.gtag
    @claim.total = current_customer.assigned_gtag_registration.gtag.gtag_credit_log.amount
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
    params.require(:epg_claim_form).permit(:country_code, :state, :city, :post_code, :phone, :address, :claim_id)
  end

  def check_has_not_claims!
    if current_customer.completed_claim
      flash.now[:error] = I18n.t('alerts.claim_complete')
      redirect_to customer_root_path
    end
  end

  def require_permission!
    @claim = Claim.find(params[:epg_claim_form][:claim_id])
    if current_customer != @claim.customer || @claim.completed?
      flash.now[:error] = I18n.t('alerts.claim_complete')
      redirect_to customer_root_path
    end
  end

end