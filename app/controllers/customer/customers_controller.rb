class Customer::CustomersController < Customer::BaseController

  def show
    @customer = Customer.find(current_customer)
  end

end