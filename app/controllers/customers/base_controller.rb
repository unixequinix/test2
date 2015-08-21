class Customers::BaseController < ApplicationController
  before_action :authenticate_customer!
  before_action :fetch_current_event

  def current_customer_event_profile
    # TODO fix the first event invocation
    current_customer.customer_event_profiles.for_event(current_event).first ||
      CustomerEventProfile.new(customer: current_customer, event: current_event)
  end
  helper_method :current_customer_event_profile

  private

  def check_has_ticket!
    redirect_to customer_root_url unless
      current_customer_event_profile.assigned_admission
  end

  def check_has_gtag!
    redirect_to customer_root_url unless
      current_customer_event_profile.assigned_gtag_registration
  end
end
