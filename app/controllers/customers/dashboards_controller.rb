class Customers::DashboardsController < Customers::BaseController

  def show
    @admission = Admission.includes(:ticket).find(current_customer.assigned_admission.id) unless current_customer.assigned_admission.nil?
    @gtag_registration = GtagRegistration.find(current_customer.assigned_gtag_registration.id) unless current_customer.assigned_gtag_registration.nil?
    @claim = current_customer.assigned_gtag_registration.gtag.claim_completed unless current_customer.assigned_gtag_registration.nil? || current_customer.assigned_gtag_registration.gtag.claim_completed.nil?
  end
end