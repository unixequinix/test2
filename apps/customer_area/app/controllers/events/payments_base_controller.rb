class Events::PaymentsBaseController < Events::BaseController

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
