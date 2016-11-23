class Events::EventsController < Events::BaseController
  def show
    @dashboard = Dashboard.new(current_customer, view_context)
  end
end
