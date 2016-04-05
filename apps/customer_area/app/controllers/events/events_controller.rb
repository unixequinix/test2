class Events::EventsController < Events::BaseController
  def show
    @dashboard = Dashboard.new(current_profile, view_context)
  end
end
