class Customer::DashboardsController < Customer::BaseController
  before_action :check_has_ticket!

  def show
    @customer = Customer.find(current_customer)
  end

  private

  def check_has_ticket!
    if current_customer.assigned_admission.nil?
      redirect_to new_customer_admission_url
    end
  end
end