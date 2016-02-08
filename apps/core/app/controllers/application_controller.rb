class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_filter :check_for_mobile

  # Get locale from user's browser and set it, unless it's present in session.
  # Use default otherwise.
  def set_locale(available_locales)
    extracted_locale =  session[:locale] ||
                        extract_locale_from_accept_language_header ||
                        I18n.default_locale
    return unless available_locales.any? { |loc| loc.to_s == extracted_locale }
    I18n.locale = extracted_locale
    session[:locale] = extracted_locale
  end

  def extract_locale_from_accept_language_header
    return if request.env["HTTP_ACCEPT_LANGUAGE"].nil?
    request.env["HTTP_ACCEPT_LANGUAGE"].scan(/^[a-z]{2}/).first
  end

  # Mobile recognition and view configuration

  def check_for_mobile
    session[:mobile_override] = (params[:mobile] == "1") ? "1" : "0"
    prepare_for_mobile if mobile_device?
  end

  def prepare_for_mobile
  end

  def mobile_device?
    (session[:mobile_override] == "1") || user_agent_mobile?
  end
  helper_method :mobile_device?

  def user_agent_mobile?
    # Note: we treat ipad as non mobile
    request.user_agent =~ (/(iPhone|iPod|Android|webOS|Mobile|iPad)/)
  end
end
