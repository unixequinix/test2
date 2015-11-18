class Events::PaymentsController < Events::BaseController
  skip_before_action :authenticate_customer!, only: [:create]
  skip_before_filter :verify_authenticity_token, only: [:create]
  skip_before_action :check_has_ticket!, only: [:create]

  def create
    payer_object = ("Payments::#{current_event.payment_service.camelize}Payer")
     .constantize.new
    payer_object.start(params)
    eval(payer_object.action_after_payment)
  end

  def success
    @admissions = current_customer_event_profile.assigned_admissions
    @dashboard = Dashboard.new(current_customer_event_profile)
    @presenter = CreditsPresenter.new(@dashboard)
  end

  def error
    @admissions = current_customer_event_profile.assigned_admissions
    @dashboard = Dashboard.new(current_customer_event_profile)
    @presenter = CreditsPresenter.new(@dashboard)
  end
end