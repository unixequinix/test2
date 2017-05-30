class Admins::EventsController < Admins::BaseController # rubocop:disable Metrics/ClassLength
  layout "admin_event"

  def index
    @status = params[:status] || "launched"
    @q = policy_scope(Event).ransack(params[:q])
    @events = @q.result
    @events = @events.with_state(@status) if @status != "all" && params[:q].blank?
    @events = @events.page(params[:page])
    render layout: "admin"
  end

  def show
    authorize @current_event
  end

  def stats
    authorize @current_event, :event_charts?
    cookies.signed[:user_id] = current_user.id
  end

  def new
    @event = Event.new
    authorize(@event)
    render layout: "admin"
  end

  def sample_event
    @event = SampleEvent.run
    authorize(@event)
    redirect_to [:admins, @event], notice: t("alerts.created")
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
      render :new, layout: "admin"
    end
  end

  def edit
    authorize @current_event
  end

  def edit_event_style
    authorize @current_event
  end

  def device_settings
    authorize @current_event
  end

  def launch
    authorize @current_event
    @current_event.update_attribute :state, "launched"
    redirect_to [:admins, @current_event], notice: t("alerts.updated")
  end

  def close
    authorize @current_event
    @current_event.update_attribute :state, "closed"
    @current_event.companies.update_all(hidden: true)
    @current_event.payment_gateways.delete_all
    redirect_to [:admins, @current_event], notice: t("alerts.updated")
  end

  def remove_db
    authorize @current_event
    @current_event.update(params[:db] => nil)
    redirect_to device_settings_admins_event_path(@current_event)
  end

  def resolve_time # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    start_date = Time.use_zone(@current_event.timezone) { @current_event.start_date }
    end_date = Time.use_zone(@current_event.timezone) { @current_event.end_date }
    time_range = (start_date.to_formatted_s(:transactions)..end_date.to_formatted_s(:transactions))
    bad_ts = @current_event.transactions.onsite.where(action: %w[sale sale_refund]).order(:device_db_index).where.not(device_created_at: time_range)
    bad_ts_id = bad_ts.pluck(:id)

    @current_event.devices.where(mac: bad_ts.pluck(:device_uid).uniq).each do |device|
      device_ts = @current_event.transactions.where(device_uid: device.mac).order(:device_db_index)
      diff = nil

      device_ts.each.with_index do |bad_t, index|
        if bad_ts_id.include?(bad_t.id)
          last_good = index.zero? ? device_ts[index] : device_ts[index - 1]
          bad_t.update!(device_created_at: start_date.to_formatted_s(:transactions)) if bad_t == last_good

          bad_date = Time.use_zone(@current_event.timezone) { Time.zone.parse(bad_t.device_created_at) }
          good_date = Time.use_zone(@current_event.timezone) { Time.zone.parse(last_good.device_created_at) }

          diff = (good_date - bad_date) if diff.nil?

          result = (bad_date + diff + 60).to_formatted_s(:transactions)
          bad_t.update!(device_created_at: result)
        else
          diff = nil
        end
      end
    end

    redirect_to request.referer, notice: "All timing issues solved"
  end

  def update
    authorize @current_event
    respond_to do |format|
      if @current_event.update(permitted_params.merge(slug: nil))
        format.html { redirect_to admins_event_path(@current_event), notice: t("alerts.updated") }
        format.json { head :ok }
      else
        flash.now[:alert] = @current_event.errors.full_messages.to_sentence
        params[:redirect_path] ||= :edit
        format.html { render params[:redirect_path].to_sym }
        format.json { render json: { errors: @current_event.errors }, status: :unprocessable_entity }
      end
    end
  end

  def remove_logo
    authorize @current_event
    @current_event.logo.destroy
    @current_event.logo.clear
    @current_event.save
    redirect_to request.referer, notice: t("alerts.destroyed")
  end

  def remove_background
    authorize @current_event
    @current_event.background.destroy
    @current_event.background.clear
    @current_event.save
    redirect_to request.referer, notice: t("alerts.destroyed")
  end

  def destroy
    authorize @current_event
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
                                  credit_attributes: %i[id name value])
  end
end
