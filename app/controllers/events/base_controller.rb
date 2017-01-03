class Events::BaseController < ApplicationController
  layout "customer"
  protect_from_forgery
  before_action :fetch_current_event
  before_action :authenticate_customer!
  before_action :write_locale_to_session
  helper_method :current_event
  helper_method :current_customer

  def prepare_for_mobile
    prepend_view_path Rails.root + "apps" + "customer_area" + "app" + "views_mobile"
  end

  private

  def write_locale_to_session
    super(Event::LOCALES.map(&:to_s))
  end

  def check_top_ups_is_active!
    redirect_to event_url(@current_event) unless @current_event.topups?
  end

  def check_has_ticket!
    redirect_to event_url(@current_event) unless current_customer.tickets.any?
  end

  def check_has_gtag!
    redirect_to event_url(@current_event) unless current_customer.active_gtag.present?
  end

  def check_customer_credentials!
    redirect_to event_url(@current_event) unless current_customer.active_credentials?
  end

  def check_has_credentials!
    check_has_gtag!
  end

  def check_authorization_flag!
    redirect_to event_info_url(@current_event) unless @current_event.authorization?
  end

  def authenticate_customer!
    redirect_to(event_login_path(@current_event)) && return unless customer_signed_in?
    redirect_to(customer_root_path(current_customer.event)) && return unless current_customer.event == @current_event
    super
  end
end
