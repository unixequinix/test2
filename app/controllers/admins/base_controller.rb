class Admins::BaseController < ApplicationController
  layout "admin"
  before_action :authenticate_user!
  before_action :write_locale_to_session
  before_action :fetch_current_event

  private

  def write_locale_to_session
    super(I18n.available_locales)
  end
end
