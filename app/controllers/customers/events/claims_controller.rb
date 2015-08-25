class Customers::Events::ClaimsController < Customers::BaseController
  before_action :check_event_status!
  before_action :check_has_gtag!
  before_action :check_has_not_claims!
  before_action :require_permission!, only: [:create]
  before_action :enough_credits!, only: [:create]

  private

  def check_event_status!
    if !current_event.claiming_started?
      flash.now[:error] = I18n.t('alerts.error')
      redirect_to customer_root_path
    end
  end

  def check_has_not_claims!
    if current_customer_event_profile.completed_claim
      flash.now[:error] = I18n.t('alerts.claim_complete')
      redirect_to customer_root_path
    end
  end

  def require_permission!
    @claim = Claim.find(params["#{current_event.refund_service}_claim_form"][:claim_id])
    if current_customer_event_profile != @claim.customer_event_profile || @claim.completed?
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

  def generate_claim(service_type)
    @claim = Claim.new
    @claim.service_type = service_type
    @claim.fee = current_event.get_parameter('refund', current_event.refund_service, 'fee')
    @claim.minimum = current_event.get_parameter('refund', current_event.refund_service, 'minimum')
    @claim.customer_event_profile = current_customer_event_profile
    @claim.gtag = current_customer_event_profile.assigned_gtag_registration.gtag
    @claim.total = current_customer_event_profile.assigned_gtag_registration.gtag.gtag_credit_log.amount * current_event.standard_credit.online_product.rounded_price
    @claim.generate_claim_number!
    @claim.save!
  end

end