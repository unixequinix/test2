class Admins::EventsController < Admins::BaseController # rubocop:disable Metrics/ClassLength
  before_action :set_event, except: %i[index new sample_event create]

  def index
    @status = params[:status] || "launched"
    @q = policy_scope(Event).ransack(params[:q])
    @events = @q.result
    authorize(@events)
    @events = @events.with_state(@status) if @status != "all" && params[:q].blank?
    @events = @events.page(params[:page])
  end

  def new
    @event = Event.new
    authorize(@event)
  end

  def sample_event
    @event = SampleEvent.run
    authorize(@event)
    redirect_to [:edit, :admins, @event], notice: t("alerts.created")
  end

  def create
    @event = Event.new(permitted_params)
    authorize(@event)

    if @event.save
      @event.event_registrations.create!(user: current_user, email: current_user.email, role: :promoter)
      @event.initial_setup!
      redirect_to admins_event_path(@event), notice: t("alerts.created")
    else
      flash[:error] = t("alerts.error")
      render :new
    end
  end

  def device_settings
    render layout: "admin_event"
  end

  def edit_event_style
    render layout: "admin_event"
  end

  def edit
    render layout: "admin_event"
  end

  def show
    render layout: "admin_event"
  end

  def resolve_time
    @bad_transactions = @current_event.transactions_with_bad_time.group_by(&:device_uid)
    render layout: "admin_event"
  end

  def do_resolve_time
    @current_event.resolve_time!
    redirect_to request.referer, notice: "All timing issues solved"
  end

  def stats
    authorize @current_event, :event_charts?
    cookies.signed[:user_id] = current_user.id
    render layout: "admin_event"
  end

  def launch
    @current_event.update_attribute :state, "launched"
    redirect_to [:admins, @current_event], notice: t("alerts.updated")
  end

  def close
    @current_event.update_attribute :state, "closed"
    @current_event.companies.update_all(hidden: true)
    @current_event.payment_gateways.delete_all
    redirect_to [:admins, @current_event], notice: t("alerts.updated")
  end

  def remove_db
    @current_event.update(params[:db] => nil)
    redirect_to device_settings_admins_event_path(@current_event)
  end

  def update
    respond_to do |format|
      if @current_event.update(permitted_params.merge(slug: nil))
        format.html { redirect_to admins_event_path(@current_event), notice: t("alerts.updated") }
        format.json { head :ok }
      else
        params[:redirect_path] ||= :edit
        format.html { render params[:redirect_path].to_sym, layout: "admin_event" }
        format.json { render json: @current_event.errors.to_json, status: :unprocessable_entity }
      end
    end
  end

  def remove_logo
    @current_event.logo.destroy
    @current_event.logo.clear
    @current_event.save
    redirect_to request.referer, notice: t("alerts.destroyed")
  end

  def remove_background
    @current_event.background.destroy
    @current_event.background.clear
    @current_event.save
    redirect_to request.referer, notice: t("alerts.destroyed")
  end

  def destroy
    transactions = @current_event.transactions
    SaleItem.where(credit_transaction_id: transactions).delete_all
    Transaction.where(id: @current_event.transactions).delete_all
    Transaction.where(catalog_item_id: @current_event.catalog_items).update_all(catalog_item_id: nil)
    @current_event.device_transactions.delete_all
    @current_event.tickets.delete_all
    @current_event.gtags.delete_all
    @current_event.destroy
    redirect_to admins_events_path(status: params[:status]), notice: t("alerts.destroyed")
  end

  private

  def set_event
    @current_event = Event.friendly.find(params[:id])
    authorize(@current_event)
  end

  def use_time_zone
    Time.use_zone(@current_event.timezone) { yield }
  end

  def permitted_params # rubocop:disable Metrics/MethodLength
    params.require(:event).permit(:action,
                                  :state,
                                  :name,
                                  :url,
                                  :start_date,
                                  :end_date,
                                  :support_email,
                                  :style,
                                  :logo,
                                  :background,
                                  :currency,
                                  :official_name,
                                  :official_address,
                                  :address,
                                  :registration_num,
                                  :eventbrite_client_key,
                                  :eventbrite_event,
                                  :timezone,
                                  :phone_mandatory,
                                  :address_mandatory,
                                  :gender_mandatory,
                                  :birthdate_mandatory,
                                  :bank_format,
                                  :private_zone_password,
                                  :fast_removal_password,
                                  :transaction_buffer,
                                  :days_to_keep_backup,
                                  :sync_time_event_parameters,
                                  :sync_time_server_date,
                                  :sync_time_basic_download,
                                  :sync_time_tickets,
                                  :sync_time_gtags,
                                  :sync_time_customers,
                                  :format,
                                  :gtag_type,
                                  :gtag_deposit,
                                  :initial_topup_fee,
                                  :topup_fee,
                                  :ultralight_c,
                                  :maximum_gtag_balance,
                                  :credit_step,
                                  :gtag_deposit_fee,
                                  :topup_fee,
                                  :card_return_fee,
                                  :token,
                                  :owner_id,
                                  :gtag_format,
                                  :stations_initialize_gtags,
                                  :stations_apply_orders,
                                  :app_version,
                                  :open_api,
                                  :open_portal,
                                  :open_refunds,
                                  :open_topups,
                                  :open_tickets,
                                  :open_gtags,
                                  :refunds_start_date,
                                  :refunds_end_date,
                                  credit_attributes: %i[id name value])
  end
end
