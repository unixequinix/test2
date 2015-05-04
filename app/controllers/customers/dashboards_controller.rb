class Customers::DashboardsController < Customers::BaseController

  def show
    ticket_credits = 0
    if !current_customer.assigned_admission.nil?
      @admission = Admission.includes(:ticket, ticket: [:ticket_type]).find(current_customer.assigned_admission.id)
      ticket_credits = @admission.ticket.ticket_type.credit
    end
    @total_credits = ticket_credits + current_customer.credits
  end
end