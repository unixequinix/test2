class Companies::BaseController < ApplicationController
  protect_from_forgery with: :null_session
  serialization_scope :view_context

  def write_locale_to_session(available_locales)
    I18n.locale = :en
    session[:locale] = :en
  end
end
