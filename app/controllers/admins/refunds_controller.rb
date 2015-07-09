class Admins::EventsController < Admins::BaseController

  def show
    @event = current_event
  end

  def edit
    @event = current_event
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

  def remove_logo
    @event = Event.friendly.find(params[:id])
    @event.update(logo: nil)
    flash[:notice] = I18n.t('alerts.destroyed')
    redirect_to admins_event_url(@event)
  end

  def remove_background
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
class Admins::RefundsController < Admins::BaseController

  def index
    @q = Refund.search(params[:q])
    @refunds = @q.result(distinct: true).page(params[:page]).includes(:claim, claim: [:gtag, :customer])
  end

  def search
    index
    render :index
  end

  def show
    @refund = Refund.find(params[:id])
  end

  def update
    @refund = Refund.find(params[:id])
    if @refund.update(permitted_params)
      flash[:notice] = I18n.t('alerts.updated')
      redirect_to admins_refund_url(@refund)
    else
      flash[:error] = I18n.t('alerts.error')
      redirect_to admins_refund_url(@refund)
    end
  end

  private

  def permitted_params
    params.require(:refund).permit(:aasm_state)
  end

end
