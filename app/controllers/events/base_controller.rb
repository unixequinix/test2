class Events::BaseController < ApplicationController
  layout 'event'
  helper_method :current_event
  before_action :fetch_current_event
  before_action :authenticate_customer!
  before_filter :set_i18n_globals

  def current_customer_event_profile
    # TODO fix the first event invocation
    current_customer.customer_event_profiles.for_event(current_event).first ||
      CustomerEventProfile.new(customer: current_customer, event: current_event)
  end
  helper_method :current_customer_event_profile

  def current_event
    @current_event || Event.new
  end

  private

  def fetch_current_event
    id = params[:event_id] || params[:id]
    @current_event = Event.friendly.find(id)
  end

  def set_i18n_globals
    I18n.config.globals[:gtag] = current_event.gtag_name
  end

  def check_has_ticket!
    redirect_to customer_root_url unless
      current_customer_event_profile.assigned_admission
  end

  def check_has_gtag!
    redirect_to customer_root_url unless
      current_customer_event_profile.assigned_gtag_registration
  end

  def authenticate_customer!
    redirect_to new_event_session_path(current_event), notice: 'if you want to add a notice' unless current_customer
  end
end