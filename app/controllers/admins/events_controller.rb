class Admins::EventsController < Admins::BaseController # rubocop:disable Metrics/ClassLength
  layout "admin_event"

  def index
    params[:status] ||= [:launched, :started, :finished]
    @status = params[:status]
    @q = policy_scope(Event).ransack(params[:q])
    @events = @q.result
    @events = @events.with_state(params[:status]) if params[:status] != "all" && params[:q].blank?
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
    @event = Event.new(permitted_params.merge(owner: current_user))
    authorize(@event)

    if @event.save
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

  def edit_gtag_settings
    authorize @current_event
  end

  def edit_device_settings
    authorize @current_event
  end

  def edit_event_style
    authorize @current_event
  end

  def gtag_settings
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

  def remove_db
    authorize @current_event
    @current_event.update(params[:db] => nil)
    redirect_to device_settings_admins_event_path(@current_event)
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
        format.json { render json: @current_event.errors, status: :unprocessable_entity }
      end
    end
  end

  def remove_logo
    authorize @current_event
    @current_event.logo.destroy
    redirect_to admins_event_path(@current_event), notice: t("alerts.destroyed")
  end

  def remove_background
    authorize @current_event
    @current_event.background.destroy
    redirect_to admins_event_path(@current_event), notice: t("alerts.destroyed")
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
                                  :info,
                                  :disclaimer,
                                  :terms_of_use,
                                  :privacy_policy,
                                  :currency,
                                  :token_symbol,
                                  :agreed_event_condition_message,
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
                                  :iban_enabled,
                                  :private_zone_password,
                                  :fast_removal_password,
                                  :touchpoint_update_online_orders,
                                  :pos_update_online_orders,
                                  :topup_initialize_gtag,
                                  :transaction_buffer,
                                  :days_to_keep_backup,
                                  :sync_time_event_parameters,
                                  :sync_time_server_date,
                                  :sync_time_basic_download,
                                  :sync_time_tickets,
                                  :sync_time_gtags,
                                  :sync_time_customers,
                                  :gtag_form_disclaimer,
                                  :format,
                                  :gtag_type,
                                  :gtag_deposit,
                                  :initial_topup_fee,
                                  :topup_fee,
                                  :ultralight_c,
                                  :mifare_classic,
                                  :ultralight_ev1,
                                  :maximum_gtag_balance,
                                  :gtag_deposit_fee,
                                  :topup_fee,
                                  :card_return_fee,
                                  credit_attributes: [:id, :name, :step, :initial_amount, :max_purchasable, :min_purchasable, :value])
  end
end
