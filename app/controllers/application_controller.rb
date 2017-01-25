class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :check_for_mobile

  attr_reader :current_event

  # Get locale from user's browser and set it, unless it's present in session.
  # Use default otherwise.
  def write_locale_to_session(available_locales)
    extracted_locale =  session[:locale] || extract_locale_from_accept_language_header || I18n.default_locale
    return unless available_locales.map(&:to_s).include?(extracted_locale)

    I18n.locale = extracted_locale
    session[:locale] = extracted_locale
  end

  def extract_locale_from_accept_language_header
    return if request.env["HTTP_ACCEPT_LANGUAGE"].nil?
    request.env["HTTP_ACCEPT_LANGUAGE"].scan(/^[a-z]{2}/).first
  end

  # Mobile recognition and view configuration

  def check_for_mobile
    session[:mobile_override] = params[:mobile] == "1" ? "1" : "0"
    prepare_for_mobile if mobile_device?
  end

  def prepare_for_mobile; end

  def mobile_device?
    (session[:mobile_override] == "1") || user_agent_mobile?
  end
  helper_method :mobile_device?

  def user_agent_mobile?
    # Note: we treat ipad as non mobile
    request.user_agent =~ /(iPhone|iPod|Android|webOS|Mobile|iPad)/
  end

  def type_cast_booleans(cols, atts)
    cols = cols.map(&:to_sym)
    cols.each { |att| atts[att] = ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include?(atts[att]) }
    atts
  end

  def validate_numeric_settings(atts); end

  private

  def fetch_current_event
    id = params[:event_id] || params[:id]
    id = current_admin.slug if current_admin&.promoter? || current_admin&.customer_service?
    return false unless id
    @current_event = Event.find_by(slug: id) || Event.find_by(id: id)
  end

  def restrict_access_with_http
    authenticate_or_request_with_http_basic do |email, token|
      admin = Admin.find_by(email: email)
      admin && admin.valid_token?(token)
    end
  end
end
