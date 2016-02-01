class Events::EventsController < Events::BaseController
  layout "welcome_customer"
  def show
    @dashboard = Dashboard.new(current_customer_event_profile, view_context)
  end
end
