class Customers::DashboardsController < Customers::BaseController
  def show
    @dashboard = Dashboard.new(current_admission)
  end
end
