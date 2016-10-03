class Admins::BaseController < ApplicationController
  layout "admin"
  protect_from_forgery
  before_action :authenticate_admin!
  before_action :write_locale_to_session

  def prepare_for_mobile
    prepend_view_path Rails.root + "apps" + "administration" + "app" + "views_mobile"
  end

  private

  def write_locale_to_session
    super(I18n.available_locales)
  end
end
