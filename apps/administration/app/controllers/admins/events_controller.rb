class Admins::EventsController < Admins::BaseController
  before_action :set_event, only: [:show, :edit, :update, :remove_logo, :remove_background, :remove_db]

  def index
    if current_admin.email.start_with?("support_")
      event = Event.find_by_slug(current_admin.email.split("_")[1].split("@")[0])
      return redirect_to(admins_event_path(event))
    end
    params[:status] ||= [:launched, :started, :finished]
    @events = params[:status] == "all" ? Event.all : Event.status(params[:status])
    @events = @events.page(params[:page])
  end

  def show
    redirect_to(admins_event_tickets_path(@current_event), layout: "admin_event") &&
      return if current_admin.customer_service?
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
    render layout: "admin_event"
  end

  def update
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
    @current_event.update(logo: nil)
    flash[:notice] = I18n.t("alerts.destroyed")
    redirect_to admins_event_url(@current_event)
  end

  def remove_background
    @current_event.update(background: nil)
    flash[:notice] = I18n.t("alerts.destroyed")
    redirect_to admins_event_url(@current_event)
  end

  def remove_db
    if params[:db] == "basic"
      @current_event.update(device_basic_db: nil)
    else
      @current_event.update(device_full_db: nil)
    end
    redirect_to admins_event_url(@current_event)
  end

  private

  def set_event
    @current_event = Event.friendly.find(params[:id])
  end

  def permitted_params
    params.require(:event)
          .permit(:aasm_state, :name, :url, :location, :start_date, :end_date, :description,
                  :support_email, :style, :logo, :background_type, :background, :features, :locales,
                  :payment_services, :refund_services, :info, :disclaimer, :host_country,
                  :gtag_assignation, :currency, :registration_parameters, :token_symbol,
                  :agreed_event_condition_message, :ticket_assignation, :company_name,
                  :agreement_acceptance, :receive_communications_message)
  end
end
