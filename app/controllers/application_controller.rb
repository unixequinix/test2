class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :exception
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  attr_reader :current_event

  # Get locale from user's browser and set it, unless it's present in session.
  # Use default otherwise.
  def write_locale_to_session(available_locales)
    extracted_locale =  session[:locale] || locale_from_language_header || I18n.default_locale
    return unless available_locales.map(&:to_s).include?(extracted_locale)

    I18n.locale = extracted_locale
    session[:locale] = extracted_locale
  end

  def locale_from_language_header
    return if request.env["HTTP_ACCEPT_LANGUAGE"].nil?
    request.env["HTTP_ACCEPT_LANGUAGE"].scan(/^[a-z]{2}/).first
  end

  private

  def user_not_authorized
    flash[:error] = I18n.t("alerts.not_authorized")
    redirect_to(request.referer || admins_events_path)
  end

  def fetch_current_event
    params[:event_id] ||= params[:id]
    @current_event = Event.find_by(slug: params[:event_id]) || Event.find_by(id: params[:event_id])
  end

  def restrict_access_with_http
    authenticate_or_request_with_http_basic do |email, token|
      admin = User.find_by(email: email)
      admin && admin.access_token.eql?(token)
    end
  end
end
