class Admins::RefundSettingsController < Admins::BaseController

  def show
    @event = current_event
    @parameters = Parameter.where(category: 'refund')
  end

  def edit
    @event = current_event
    @parameters = Parameter.where(category: 'refund')
  end

  def update
    @event = Event.friendly.find(params[:id])
    if @event.update(permitted_params)
      flash[:notice] = I18n.t('alerts.updated')
      @event.slug = nil
      @event.save!
      redirect_to admins_event_url(@event)
    else
      flash[:error] = I18n.t('alerts.error')
      render :edit
    end
  end

  def notify_customers
    @event = Event.friendly.find(params[:id])
    @event.update(background: nil)
    flash[:notice] = I18n.t('alerts.destroyed')
    redirect_to admins_event_url(@event)
  end

  private

  def permitted_params
    params.require(:event).permit(:aasm_state, :name, :url, :location, :start_date, :end_date, :description, :support_email, :style, :logo, :background_type, :background, :features, :refund_service, :gtag_registration, :info, :disclaimer)
  end

end
