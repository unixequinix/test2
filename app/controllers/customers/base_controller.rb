class Customers::BaseController < ApplicationController
  before_action :authenticate_customer!
  before_action :fetch_current_event

  def current_customer_event_profile
    current_customer.customer_event_profiles.for_event(current_event).first || Admission.new
  end
  helper_method :current_customer_event_profile

  private

  def check_has_ticket!
    redirect_to customer_root_url unless current_customer_event_profile.assigned_admittance
  end

  def check_has_gtag!
    if current_customer.assigned_gtag_registration.nil?
      redirect_to customer_root_url
    end
  end
end
