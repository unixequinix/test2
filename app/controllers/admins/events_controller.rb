class Admins::EventsController < Admins::BaseController
  include ReportsHelper

  before_action :set_event, except: %i[index new sample_event create]
  before_action :set_event_series, only: %i[new edit]
  before_action :set_versions, only: %i[show edit]

  def index
    @status = params[:status] || "launched"
    @q = policy_scope(Event).ransack(params[:q])
    @events = @q.result
    authorize(@events)
    @events = @events.with_state(@status) if @status.in?(Event.states.keys) && params[:q].blank?
    @events = @current_user.events if @status.eql?("users") && params[:q].blank?
    @events = @events.order(state: :asc, start_date: :desc).page(params[:page])
    @alerts = Alert.where(event_id: @events).unresolved.group(:event_id).count
  end

  def new
    @event = Event.new
    authorize(@event)
  end

  def edit
    render layout: "admin_event"
  end

  def refund_fields
    render layout: "admin_event"
  end

  def show
    credit = @current_event.credit
    virtual = @current_event.virtual_credit
    all_credits = [credit, virtual]

    token_symbol = @current_event.credit.symbol
    currency_symbol = @current_event.currency_symbol

    activations = Poke.connection.select_all(query_activations(@current_event.id)).map { |h| h["Activations"] }.compact.sum
    total_sale = -@current_event.pokes.where(credit: all_credits).sales.is_ok.sum(:credit_amount)

    @total_money = @current_event.pokes.is_ok.sum(:monetary_total_price)
    @total_credits = @current_event.pokes.where(credit: all_credits).is_ok.sum(:credit_amount)
    @total_products_sale = total_sale
    @total_checkins = @current_event.tickets.where(redeemed: true).count
    @total_activations = activations
    @total_devices = @current_event.pokes.is_ok.devices.map { |h| h["total_devices"] }.compact.sum

    @token_symbol = token_symbol
    @record_credit_sales = @current_event.pokes.record_credit_sale_h.is_ok.where(credit: all_credits).to_json
    render layout: "admin_event"
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

  def update
    respond_to do |format|
      if @current_event.update(permitted_params.merge(slug: nil))
        format.html { redirect_to [:admins, @current_event], notice: t("alerts.updated") }
        format.json { render json: @current_event }
      else
        format.html { render :edit, layout: "admin_event" }
        format.json { render json: @current_event.errors.to_json, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    transactions = @current_event.transactions
    SaleItem.where(credit_transaction_id: transactions).delete_all
    Transaction.where(id: transactions).delete_all
    catalog_items = @current_event.catalog_items.pluck(:id)
    Transaction.where(catalog_item_id: catalog_items).update_all(catalog_item_id: nil)
    @current_event.device_transactions.delete_all
    @current_event.tickets.delete_all
    @current_event.gtags.delete_all
    @current_event.destroy
    redirect_to admins_events_path(status: params[:status]), notice: t("alerts.destroyed")
  end

  def versions
    @versions = @current_event.versions.reorder(created_at: :desc).page(params[:page])
    render layout: "admin_event"
  end

  def sample_event
    @event = SampleEvent.run(@current_user)
    @event.event_registrations.create!(user: current_user, email: current_user.email, role: :promoter)
    authorize(@event)
    redirect_to [:admins, @event], notice: t("alerts.created")
  end

  def resolve_time
    @bad_transactions = @current_event.transactions_with_bad_time.group_by(&:device_uid)
    render layout: "admin_event"
  end

  def do_resolve_time
    @current_event.resolve_time!
    redirect_to request.referer, notice: "All timing issues solved"
  end

  def launch
    @current_event.update_attribute :state, "launched"
    redirect_to request.referer, notice: t("alerts.updated")
  end

  def close
    @current_event.update_attribute :state, "closed"
    @current_event.companies.update_all(hidden: true)
    @current_event.device_registrations.update_all(allowed: true)

    redirect_to [:admins, @current_event], notice: t("alerts.updated")
  end

  def remove_db
    @current_event.update(params[:db] => nil)
    redirect_to admins_event_device_registrations_path(@current_event)
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

  private

  def set_event_series
    @event_series = EventSerie.all
    authorize(@event_series)
  end

  def set_event
    @current_event = Event.friendly.find(params[:id])
    authorize(@current_event)
  end

  def set_versions
    @versions = @current_event.versions.reorder(created_at: :desc).limit(10)
  end

  def use_time_zone
    Time.use_zone(@current_event.timezone) { yield }
  end

  def permitted_params
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
                                  :onsite_initial_topup_fee,
                                  :online_initial_topup_fee,
                                  :every_topup_fee,
                                  :refund_fee,
                                  :refund_minimum,
                                  :auto_refunds,
                                  :ultralight_c,
                                  :maximum_gtag_balance,
                                  :credit_step,
                                  :gtag_deposit_fee,
                                  :card_return_fee,
                                  :token,
                                  :owner_id,
                                  :gtag_format,
                                  :stations_initialize_gtags,
                                  :stations_apply_orders,
                                  :stations_apply_tickets,
                                  :tips_enabled,
                                  :app_version,
                                  :open_api,
                                  :open_devices_api,
                                  :open_ticketing_api,
                                  :open_portal,
                                  :open_portal_intercom,
                                  :open_refunds,
                                  :open_topups,
                                  :open_tickets,
                                  :open_gtags,
                                  :refunds_start_date,
                                  :refunds_end_date,
                                  :event_serie_id,
                                  :accounting_code,
                                  credit_attributes: %i[id name value],
                                  refund_fields: [])
  end
end
