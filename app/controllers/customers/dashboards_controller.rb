class Customers::DashboardsController < Customers::BaseController
  def show
    @dashboard = DashboardPresenter.new(current_admission)
  end
end
