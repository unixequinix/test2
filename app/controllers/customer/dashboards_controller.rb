class Customer::DashboardsController < Customer::BaseController
  before_action :check_has_ticket!

  def show
    @admission = Admission.includes(:ticket, ticket: [:ticket_type]).find(current_customer.id)
  end
end