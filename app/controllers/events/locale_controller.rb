class Events::LocaleController < Events::EventsController
  skip_before_action :authenticate_customer!

  # Change the locale in the session
  def change
    session[:locale] = params[:id]
    I18n.locale = params[:id]
    current_customer&.update(locale: I18n.locale)
    redirect_to(@current_event)
  end
end
