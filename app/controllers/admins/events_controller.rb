class Admins::EventsController < Admins::BaseController # rubocop:disable Metrics/ClassLength
  include ActiveModel::Dirty

  def index
    redirect_to(admins_event_path(Event.find_by(slug: current_admin.slug))) && return if current_admin.customer_service? || current_admin.promoter?

    params[:status] ||= [:launched, :started, :finished]
    @events = params[:status] == "all" ? Event.all : Event.status(params[:status])
    @events = @events.page(params[:page])
  end

  def show
    render layout: "admin_event"
  end

  def new
    @event = Event.new
  end

  def create # rubocop:disable Metrics/MethodLength
    @event = Event.new(permitted_params)

    if @event.save
      @event.create_credit!(value: 1, name: "CRD", step: 5, min_purchasable: 0, max_purchasable: 300, initial_amount: 0)
      UserFlag.create!(event_id: @event.id, name: "alcohol_forbidden", step: 1)
      station = @event.stations.create! name: "Customer Portal", category: "customer_portal", group: "access"
      station.station_catalog_items.create(catalog_item: @event.credit, price: 1)
      @event.stations.create! name: "CS Topup/Refund", category: "cs_topup_refund", group: "event_management"
      @event.stations.create! name: "CS Accreditation", category: "cs_accreditation", group: "event_management"
      @event.stations.create! name: "Glownet Food", category: "hospitality_top_up", group: "event_management"
      @event.stations.create! name: "Touchpoint", category: "touchpoint", group: "touchpoint"
      @event.stations.create! name: "Operator Permissions", category: "operator_permissions", group: "event_management"
      @event.stations.create! name: "Gtag Recycler", category: "gtag_recycler", group: "glownet"
      redirect_to admins_event_url(@event), notice: I18n.t("events.create.notice")
    else
      flash[:error] = I18n.t("events.create.error")
      render :new
    end
  end

  def edit
    render layout: "admin_event"
  end

  def update
    if @current_event.update(permitted_params.merge(slug: nil))
      cols = %w(name start_date end_date)
      @current_event.update(device_full_db: nil, device_basic_db: nil) if @current_event.changes.keys.any? { |att| cols.include? att }
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

  def create_admin
    @admin = Admin.find_or_initialize_by(email: "admin_#{@current_event.slug}@glownet.com")
    if @admin.new_record?
      render 'admins/admins/new'
    else
      render 'admins/admins/edit'
    end
  end

  def create_customer_support
    @admin = Admin.find_or_initialize_by(email: "support_#{@current_event.slug}@glownet.com")
    if @admin.new_record?
      render 'admins/admins/new'
    else
      render 'admins/admins/edit'
    end
  end

  private

  def permitted_params # rubocop:disable Metrics/MethodLength
    params.require(:event).permit(:state,
                                  :name,
                                  :url,
                                  :start_date,
                                  :end_date,
                                  :support_email,
                                  :style,
                                  :logo,
                                  :background_type,
                                  :background,
                                  :info,
                                  :disclaimer,
                                  :terms_of_use,
                                  :privacy_policy,
                                  :gtag_assignation,
                                  :currency,
                                  :token_symbol,
                                  :agreed_event_condition_message,
                                  :ticket_assignation,
                                  :company_name,
                                  :agreement_acceptance,
                                  :official_name,
                                  :official_address,
                                  :receive_communications_message,
                                  :receive_communications_two_message,
                                  :address,
                                  :registration_num,
                                  :eventbrite_client_key,
                                  :eventbrite_event,
                                  :timezone,
                                  :ticket_assignation,
                                  :gtag_assignation,
                                  :phone_mandatory,
                                  :address_mandatory,
                                  :city_mandatory,
                                  :country_mandatory,
                                  :postcode_mandatory,
                                  :gender_mandatory,
                                  :birthdate_mandatory,
                                  :agreed_event_condition,
                                  :receive_communications,
                                  :receive_communications_two,
                                  :iban_enabled)
  end
end
