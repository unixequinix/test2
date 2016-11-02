class Admins::LocaleController < Admins::BaseController
  skip_before_action :fetch_current_event

  # Change the locale in the session
  def change
    session[:locale] = params[:id]
    I18n.locale = params[:id]
    redirect_to :back
  end
end
