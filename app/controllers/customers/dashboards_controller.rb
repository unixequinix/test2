class Customers::DashboardsController < Customers::BaseController

  def show
    if !current_customer.assigned_admission.nil?
      @admission = Admission.includes(:ticket).find(current_customer.assigned_admission.id)
    end
  end
end