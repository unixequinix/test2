class Events::LocaleController < Events::BaseController
  skip_before_action :authenticate_customer!

  # Change the locale in the session
  def change
    session[:locale] = params[:id]
    redirect_to(current_event)
  end
end