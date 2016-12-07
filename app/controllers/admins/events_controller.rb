class Admins::EventsController < Admins::BaseController
  include ActiveModel::Dirty

  before_action :set_event, only: [:show, :edit, :update, :remove_logo, :remove_background, :remove_db]

  def index
    if current_admin.customer_service? || current_admin.promoter?
      event = Event.find_by_slug(current_admin.email.split("_")[1].split("@")[0])
      redirect_to(admins_event_path(event)) && return
    end
    params[:status] ||= [:launched, :started, :finished]
    @events = params[:status] == "all" ? Event.all : Event.status(params[:status])
    @events = @events.page(params[:page])
  end

  def show
    # TODO: Remove this when we have roles, this was a workaround for sonar, but as a lot of things it still  here
    redirect_to(admins_event_tickets_path(@current_event), layout: "admin_event") &&
      return if current_admin.customer_service?
    @alerts = EventValidator.new(current_event).all
    render layout: "admin_event"
  end

  def new
    @event = Event.new(default_settings)
  end

  def create
    event_creator = EventCreator.new(permitted_params)
    if event_creator.save
      redirect_to admins_event_url(event_creator.event), notice: I18n.t("events.create.notice")
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
    if @current_event.update(permitted_params.merge(slug: nil))
      previous_changes = @current_event.previous_changes
      if previous_changes[:name] || previous_changes[:start_date] || previous_changes[:end_date]
        @current_event.update(device_full_db: nil, device_basic_db: nil)
      end

      redirect_to admins_event_url(@current_event), notice: I18n.t("alerts.updated")
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

  private

  def set_event
    @current_event = Event.friendly.find(params[:id])
  end

  def permitted_params
    params.require(:event)
          .permit(:aasm_state, :name, :url, :location, :start_date, :end_date, :support_email, :style,
                  :logo, :background_type, :background, :info, :disclaimer, :terms_of_use, :privacy_policy,
                  :host_country, :gtag_assignation, :currency, :token_symbol, :agreed_event_condition_message,
                  :ticket_assignation, :company_name, :agreement_acceptance, :official_name, :official_address,
                  :receive_communications_message, :receive_communications_two_message, :address, :registration_num,
                  :eventbrite_client_key, :eventbrite_event, registration_settings: Event::REGISTRATION_SETTINGS)
  end

  def default_settings
    {
      registration_settings: {
        phone: false,
        address: false,
        city: false,
        country: false,
        postcode: false,
        gender: false,
        birthdate: false,
        agreed_event_condition: false,
        receive_communications: false,
        receive_communications_two: false
      }.as_json
    }
  end
end
