class Customers::DashboardsController < Customers::BaseController

  def show
    @admission = Admission.includes(:ticket).find(current_customer.assigned_admission.id) unless current_customer.assigned_admission.nil?
    @gtag_registration = GtagRegistration.find(current_customer.assigned_gtag_registration.id) unless current_customer.assigned_gtag_registration.nil?
    @refund = Refund.find(current_customer.refund.id) unless current_customer.assigned_gtag_registration.nil? || current_customer.refund.nil?
  end
end