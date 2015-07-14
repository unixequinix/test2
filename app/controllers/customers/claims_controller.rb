class Customers::ClaimsController < Customers::BaseController
  before_action :check_has_gtag!
  before_action :check_has_not_claims!
  before_action :require_permission!, only: [:create]
  before_action :enough_credits!, only: [:create]

  private

  def check_has_not_claims!
    if current_customer.completed_claim
      flash.now[:error] = I18n.t('alerts.claim_complete')
      redirect_to customer_root_path
    end
  end

  def require_permission!
    @claim = Claim.find(params["#{current_event.refund_service}_claim_form"][:claim_id])
    if current_customer != @claim.customer || @claim.completed?
      flash.now[:error] = I18n.t('alerts.claim_complete')
      redirect_to customer_root_path
    end
  end

  def enough_credits!
    @claim = Claim.find(params["#{current_event.refund_service}_claim_form"][:claim_id])
    if !@claim.enough_credits?
      flash.now[:error] = I18n.t('alerts.quantity_not_refundable')
      redirect_to customer_root_path
    end
  end

end