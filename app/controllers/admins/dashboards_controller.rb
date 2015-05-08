class Admins::DashboardsController < Admins::BaseController
  def show
    @event = current_event
  end
end
