class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_locale

  private

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

end
