class Admins::Events::CredentialAssignmentsController < Admins::Events::CheckinBaseController

  def current_customer
    @fetcher.customers.find(params[:customer_id])
  end

  def current_customer_event_profile
    current_customer.customer_event_profile ||
      CustomerEventProfile.new(customer: current_customer, event: current_event)
  end

end