class Events::EventsController < Events::BaseController
  layout "dashboard_customer"
  def show
    @dashboard = Dashboard.new(current_customer_event_profile, view_context)
  end
end
