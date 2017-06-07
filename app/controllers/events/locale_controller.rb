class Events::LocaleController < Events::EventsController
  include LanguageHelper
  skip_before_action :authenticate_customer!
  skip_before_action :check_portal_open

  def change
    update_locale(params[:id])
    current_customer&.update(locale: params[:id])

    redirect_to(request.referer || customer_root_path(current_event))
  end
end
