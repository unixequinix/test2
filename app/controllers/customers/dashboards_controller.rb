class Customers::DashboardsController < Customers::BaseController
  def show
    @admission = current_admission
    @gtag_registration = GtagRegistration.find(current_customer.assigned_gtag_registration.id) unless current_customer.assigned_gtag_registration.nil?
    @refund = Refund.find(current_customer.refund.id) unless current_customer.assigned_gtag_registration.nil? || current_customer.refund.nil?
  end
end
