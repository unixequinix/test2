class Events::ClaimsController < Events::BaseController
  before_action :check_event_status!
  before_action :check_has_gtag!
  before_action :check_has_not_claims!
  before_action :require_permission!, only: [:create]
  before_action :enough_credits!, only: [:new, :create]

  private

  def check_event_status!
    if !current_event.claiming_started?
      flash.now[:error] = I18n.t('alerts.error')
      redirect_to event_url(current_event)
    end
  end

  def check_has_not_claims!
    if current_customer_event_profile.completed_claim
      flash.now[:error] = I18n.t('alerts.claim_complete')
      redirect_to event_url(current_event)
    end
  end

  def require_permission!
    @claim = Claim.find(params["#{service_type}_claim_form"][:claim_id])
    if current_customer_event_profile != @claim.customer_event_profile || @claim.completed?
      flash.now[:error] = I18n.t('alerts.claim_complete')
      redirect_to event_url(current_event)
    end
  end

  def enough_credits!
    @gtag = current_customer_event_profile.assigned_gtag_registration.gtag
    if !@gtag.refundable?(service_type)
      flash.now[:error] = I18n.t('alerts.quantity_not_refundable')
      redirect_to event_url(current_event)
    end
  end

  def generate_claim
    @claim = Claim.new
    @claim.service_type = service_type
    @claim.fee = current_event.refund_fee(service_type)
    @claim.minimum = current_event.refund_minimun(service_type)
    @claim.customer_event_profile = current_customer_event_profile
    @claim.gtag = current_customer_event_profile.assigned_gtag_registration.gtag
    @claim.total = current_customer_event_profile.assigned_gtag_registration.gtag.gtag_credit_log.amount * current_event.standard_credit.online_product.rounded_price
    @claim.generate_claim_number!
    @claim.save!
    @claim
  end

end