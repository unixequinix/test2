class Customers::Events::DashboardsController < Customers::BaseController
  def show
    @dashboard = Dashboard.new(current_customer_event_profile)
  end
end
