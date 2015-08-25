class Customers::BaseController < ApplicationController
  before_action :authenticate_customer!
  helper_method :current_event
  before_action :fetch_current_event
  before_filter :set_i18n_globals

  # TODO Do this somewhere else other than the global space
  def current_event
    @current_event || Event.new
  end

  def current_customer_event_profile
    # TODO fix the first event invocation
    current_customer.customer_event_profiles.for_event(current_event).first ||
      CustomerEventProfile.new(customer: current_customer, event: current_event)
  end
  helper_method :current_customer_event_profile

  private

  def fetch_current_event
    id = params[:event_id] || params[:id]
    # @current_event = Event.friendly.find(id)
    @current_event = Event.first
    # TODO User authentication
  end

  def check_has_ticket!
    redirect_to customer_root_url unless
      current_customer_event_profile.assigned_admission
  end

  def check_has_gtag!
    redirect_to customer_root_url unless
      current_customer_event_profile.assigned_gtag_registration
  end

  def set_i18n_globals
    I18n.config.globals[:gtag] = current_event.gtag_name
  end
end
