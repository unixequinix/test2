class Events::BaseController < ApplicationController
  layout "customer"
  protect_from_forgery
  before_action :fetch_current_event
  before_action :ensure_customer
  before_action :write_locale_to_session
  before_filter :set_i18n_globals
  helper_method :current_event
  before_action :authenticate_customer!
  helper_method :warden, :customer_signed_in?, :current_customer

  def warden
    request.env["warden"]
  end

  def authenticate_customer!
    logout_customer! if customer_signed_in? && current_customer&.event != current_event
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
    return nil if warden.user(:customer).nil?
    Customer.find_by(id: warden.user(:customer)["id"])
  end

  def current_profile
    current_customer.profile || Profile.new(customer: current_customer, event: current_event)
  end
  helper_method :current_profile

  def prepare_for_mobile
    prepend_view_path Rails.root + "apps" + "customer_area" + "app" + "views_mobile"
  end

  private

  def write_locale_to_session
    super(current_event.selected_locales_formated)
  end

  def set_i18n_globals
    I18n.config.globals[:gtag] = current_event.gtag_name
  end

  def check_top_ups_is_active!
    redirect_to event_url(current_event) unless current_event.top_ups?
  end

  def check_has_ticket!
    redirect_to event_url(current_event) unless current_profile.active_tickets_assignment
  end

  def check_has_gtag!
    redirect_to event_url(current_event) unless current_profile.active_gtag_assignment
  end

  def check_authorization_flag!
    redirect_to event_info_url(current_event) unless current_event.authorization?
  end
end
