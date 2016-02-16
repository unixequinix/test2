class Admins::EventsController < Admins::BaseController
  def index
    @events = Event.all.page(params[:page])
  end

  def show
    @current_event = Event.friendly.find(params[:id])
    render layout: "admin_event"
  end

  def new
    @event = Event.new
  end

  def create
    event_creator = EventCreator.new(permitted_params)
    if event_creator.save
      flash[:notice] = I18n.t("events.create.notice")
      redirect_to admins_event_url(event_creator.event)
    else
      ## TODO HANDLE ERROR
      flash[:error] = I18n.t("events.create.error")
      @event = event_creator.event
      render :new
    end
  end

  def edit
    @current_event = Event.friendly.find(params[:id])
    render layout: "admin_event"
  end

  def update
    @current_event = Event.friendly.find(params[:id])
    if @current_event.update_attributes(permitted_params)
      flash[:notice] = I18n.t("alerts.updated")
      @current_event.slug = nil
      @current_event.save!
      redirect_to admins_event_url(@current_event)
    else
      flash[:error] = I18n.t("alerts.error")
      render :edit
    end
  end

  def remove_logo
    @current_event = Event.friendly.find(params[:id])
    @current_event.update(logo: nil)
    flash[:notice] = I18n.t("alerts.destroyed")
    redirect_to admins_event_url(@current_event)
  end

  def remove_background
    @current_event = Event.friendly.find(params[:id])
    @current_event.update(background: nil)
    flash[:notice] = I18n.t("alerts.destroyed")
    redirect_to admins_event_url(@current_event)
  end

  def permitted_params
    params.require(:event)
      .permit(:aasm_state, :name, :url, :location, :start_date, :end_date, :description,
              :support_email, :style, :logo, :background_type, :background, :features, :locales,
              :payment_service, :refund_services, :info, :disclaimer, :host_country,
              :gtag_assignation, :currency, :registration_parameters,
              :agreed_event_condition_message, :ticket_assignation)
  end
end
