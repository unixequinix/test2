class Events::BaseController < ApplicationController
  layout "event"
  protect_from_forgery
  before_action :ensure_customer
  before_action :set_locale
  before_filter :set_i18n_globals
  helper_method :current_event
  before_action :fetch_current_event
  before_action :authenticate_customer!
  helper_method :warden, :customer_signed_in?, :current_customer

  def current_event
    @current_event || Event.new
  end

  def warden
    request.env["warden"]
  end

  def authenticate_customer!
    logout_customer! if customer_signed_in? && current_customer.event != current_event
    warden.authenticate!(scope: :customer)
  end

  def logout_customer!
    warden.logout(:customer)
  end

  def ensure_customer
    return if customer_signed_in?
    logout_customer!
    false
  end

  def customer_signed_in?
    !current_customer.nil?
  end

  def current_customer
    @current_customer ||=
      Customer.find(warden.user(:customer)["id"]) unless
      warden.user(:customer).nil? ||
      Customer.where(id: warden.user(:customer)["id"]).empty?
  end

  def current_customer_event_profile
    current_customer.customer_event_profile ||
      CustomerEventProfile.new(customer: current_customer, event: current_event)
  end
  helper_method :current_customer_event_profile

  private

  def fetch_current_event
    id = params[:event_id] || params[:id]
    @current_event = Event.find_by_slug(id) if id
    fail ActiveRecord::RecordNotFound if @current_event.nil?
    @current_event
  end

  def set_locale
    super(current_event.selected_locales_formated)
  end

  def set_i18n_globals
    I18n.config.globals[:gtag] = current_event.gtag_name
  end

  def check_top_ups_is_active!
    redirect_to event_url(current_event) unless
      current_event.top_ups?
  end

  def check_has_ticket!
    redirect_to event_url(current_event) unless
      current_customer_event_profile.active_tickets_assignment
  end

  def check_has_gtag!
    redirect_to event_url(current_event) unless
      current_customer_event_profile.active_gtag_assignment
  end
end
