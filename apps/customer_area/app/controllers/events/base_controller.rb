class Events::BaseController < ApplicationController
  layout 'event'
  protect_from_forgery
  before_filter :set_i18n_globals
  before_action :ensure_customer
  before_action :authenticate_customer!

  helper_method :warden, :customer_signed_in?, :current_customer

  def warden
    request.env['warden']
  end

  def authenticate_customer!
    if current_customer && current_customer.event != current_event
      logout_customer!
      redirect_to customer_root_path(current_event)
    else
      redirect_to event_login_path(current_event) unless current_customer
    end
  end

  def logout_customer!
    warden.logout(:customer)
  end

  def ensure_customer
    unless customer_signed_in?
      logout_customer!
      return false
    end
  end

  def customer_signed_in?
    !current_customer.nil?
  end

  def current_customer
    if warden.authenticated?(:customer)
      @current_customer ||= Customer.find(warden.user(:customer)["id"]) unless
        warden.user(:customer).nil? ||
        Customer.where(id: warden.user(:customer)["id"]).empty?
    else
      @current_customer = warden.authenticate(:customer_password, scope: :customer)
    end
  end

  def current_customer_event_profile
    current_customer.customer_event_profile ||
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
end