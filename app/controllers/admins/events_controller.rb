class Admins::EventsController < Admins::BaseController

  def update
    @event = Event.find(params[:id])
    if @event.update(permitted_params)
      flash[:notice] = "updated TODO"
      redirect_to admin_root_url
    else
      flash[:error] = "ERROR"
      render :edit
    end
  end

  private

  def permitted_params
    params.require(:event).permit(:aasm_state)
  end

end
