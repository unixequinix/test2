class Events::LocaleController < Events::EventsController
  include LanguageHelper
  skip_before_action :authenticate_customer!

  def change
    update_locale(params[:id])
    current_customer&.update(locale: params[:id])

    redirect_to(request.referer)
  end
end
