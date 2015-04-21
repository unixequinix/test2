class Customer::DashboardsController < Customer::BaseController

  def show
    @customer = Customer.find(current_customer)
  end

end