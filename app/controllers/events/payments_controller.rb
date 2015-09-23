class Events::PaymentsController < Events::BaseController
  skip_before_action :authenticate_customer!, only: [:create]
  skip_before_filter :verify_authenticity_token, only: [:create]
  skip_before_action :check_has_ticket!, only: [:create]

  def create
    payment_notifier =
      ("Payments::#{current_event.payment_service.camelize}Notifier")
        .constantize.new
    payment_notifier.notify_payment(params)
    render nothing: true
  end

  def success
    if !current_customer_event_profile.assigned_admission.nil?
      @admission = Admission.find(current_customer_event_profile.assigned_admission.id)
    end
    # TODO User credits partial as a separated entity
    @dashboard = Dashboard.new(current_customer_event_profile)
    @presenter = CreditsPresenter.new(@dashboard)
  end

  def error
    if !current_customer_event_profile.assigned_admission.nil?
      @admission = Admission.find(current_customer_event_profile.assigned_admission.id)
    end
    # TODO User credits partial as a separated entity
    @dashboard = Dashboard.new(current_customer_event_profile)
    @presenter = CreditsPresenter.new(@dashboard)
  end

end