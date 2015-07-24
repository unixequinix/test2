class Customers::DashboardsController < Customers::BaseController

  def show
    @admission = Admission.includes(:ticket).find(current_customer.assigned_admission.id) unless current_customer.assigned_admission.nil?
    @gtag_registration = GtagRegistration.find(current_customer.assigned_gtag_registration.id) unless current_customer.assigned_gtag_registration.nil?
    @claim = current_customer.assigned_gtag_registration.gtag.completed_claim unless current_customer.assigned_gtag_registration.nil? || current_customer.assigned_gtag_registration.gtag.completed_claim.nil?
    @fee = EventParameter.find_by(event_id: current_event.id, parameter_id: Parameter.find_by(category: 'refund', group: current_event.refund_service, name: 'fee')).value
    @minimum = EventParameter.find_by(event_id: current_event.id, parameter_id: Parameter.find_by(category: 'refund', group: current_event.refund_service, name: 'minimum')).value
  end
end