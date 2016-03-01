class Events::PaymentsController < Events::BaseController
  skip_before_action :authenticate_customer!, only: [:create]
  skip_before_filter :verify_authenticity_token, only: [:create]
  skip_before_action :check_has_ticket!, only: [:create]

  def create
    payer = ("Payments::#{current_event.payment_service.camelize}Payer").constantize.new
    payer.start(params, CustomerOrderCreator.new)
    eval(payer.action_after_payment)
  end

  def success
    @admissions = current_customer_event_profile.active_tickets_assignment
    @dashboard = Dashboard.new(current_customer_event_profile, view_context)
    @presenter = CreditsPresenter.new(@dashboard, view_context)
  end

  def error
    @admissions = current_customer_event_profile.active_tickets_assignment
    @dashboard = Dashboard.new(current_customer_event_profile, view_context)
    @presenter = CreditsPresenter.new(@dashboard, view_context)
  end
end
