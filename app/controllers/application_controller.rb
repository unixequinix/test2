class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_locale
  helper_method :current_event
  before_filter :check_for_mobile

  # TODO Do this somewhere else other than the global space
  def current_event
    @current_event ||= Event.first
  end

  private

  def fetch_current_event
    @current_event = Event.first
    # TODO User authentication
  end

  def after_sign_out_path_for(resource)
    return admin_root_path if resource == :admin
    return customer_root_path if resource == :customer
    root_path
  end

  # Get locale from user's browser and set it, unless it's present in session.
  # Use default otherwise.
  def set_locale
    extracted_locale =  session[:locale] ||
                        extract_locale_from_accept_language_header ||
                        I18n.default_locale
    if I18n.available_locales.any? { |loc| loc.to_s == extracted_locale }
      I18n.locale = extracted_locale
      session[:locale] = extracted_locale
    end
  end

  def extract_locale_from_accept_language_header
    if not request.env['HTTP_ACCEPT_LANGUAGE'].nil?
      request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
    end
  end

  # Mobile recognition and view configuration

  def check_for_mobile
    session[:mobile_override] = (params[:mobile] == '1') ? '1' : '0'
    prepare_for_mobile if mobile_device?
  end

  def prepare_for_mobile
    prepend_view_path Rails.root + 'app' + 'views_mobile'
  end

  def mobile_device?
    (session[:mobile_override] == '1') || user_agent_mobile?
  end

  def user_agent_mobile?
    # Note: we treat ipad as non mobile
    request.user_agent =~ (/(iPhone|iPod|Android|webOS|Mobile|iPad)/)
  end

  helper_method :mobile_device?
end
