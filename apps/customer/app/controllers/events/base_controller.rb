class Events::BaseController < ApplicationController
  layout 'event'
  before_action :authenticate_customer!
  before_filter :set_i18n_globals

  def current_customer_event_profile
    # TODO fix the first event invocation
    current_customer.customer_event_profiles.for_event(current_event).first ||
      CustomerEventProfile.new(customer: current_customer, event: current_event)
  end
  helper_method :current_customer_event_profile

  private

  def set_i18n_globals
    I18n.config.globals[:gtag] = current_event.gtag_name
  end

  def check_top_ups_is_active!
    redirect_to event_url(current_event) unless
      current_event.top_ups?
  end

  def check_has_ticket!
    redirect_to event_url(current_event) unless
      current_customer_event_profile.assigned_admissions
  end

  def check_has_gtag!
    redirect_to event_url(current_event) unless
      current_customer_event_profile.assigned_gtag_registration
  end

  def authenticate_customer!
    if current_customer && current_customer.event != current_event
      sign_out(current_customer)
      redirect_to event_url(current_event)
    else
      redirect_to new_customer_event_session_path(current_event) unless current_customer
    end
  end
end