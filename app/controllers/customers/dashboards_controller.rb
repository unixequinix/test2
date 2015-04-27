class Customers::DashboardsController < Customers::BaseController
  before_action :check_has_ticket!

  def show
    @admission = Admission.includes(:ticket, ticket: [:ticket_type]).find(current_customer.assigned_admission.id)
  end
end