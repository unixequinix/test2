class Events::InfosController < Events::BaseController
  layout "welcome_customer"
  skip_before_action :authenticate_customer!

  def show
    redirect_to(event_path(@current_event)) && return if @current_event.authorization?
  end
end
