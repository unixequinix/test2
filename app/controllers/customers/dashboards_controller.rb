class Customers::DashboardsController < Customers::BaseController
  def show
    @admission = current_admission
    @gtag_registration = current_admission.assigned_gtag_registration
    @refund = current_customer.refund
  end
end
