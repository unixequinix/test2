class Admins::EventsController < Admins::BaseController # rubocop:disable Metrics/ClassLength
  def index
    params[:status] ||= [:launched, :started, :finished]
    @status = params[:status]
    @q = policy_scope(Event).ransack(params[:q])
    @events = @q.result
    @events = @events.with_state(params[:status]) if params[:status] != "all" && params[:q].blank?
    @events = @events.page(params[:page])
  end

  def show
    authorize @current_event
    render layout: "admin_event"
  end

  def transactions_chart
    result = %w(access credential credit money).map { |type| { name: type, data: @current_event.transactions.send(type).group_by_day(:created_at).count } } # rubocop:disable Metrics/LineLength
    authorize @current_event, :event_charts?
    render json: result.chart_json
  end

  def credits_chart
    result = %w(sale topup).map do |action|
      data = @current_event.transactions.credit.where(action: action).group_by_day(:created_at).sum(:credits)
      data = data.collect { |k, v| [k, v.to_i.abs] }
      { name: action, data: Hash[data] }
    end
    authorize @current_event, :event_charts?
    render json: result.chart_json
  end

  def new
    @event = Event.new
    authorize(@event)
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
      render :new
    end
  end

  def edit
    authorize @current_event
    render layout: "admin_event"
  end

  def update
    authorize @current_event
    respond_to do |format|
      if @current_event.update(permitted_params.merge(slug: nil))
        format.html { redirect_to admins_event_path(@current_event), notice: t("alerts.updated") }
        format.json { render :show, status: :ok, location: @current_event }
      else
        flash.now[:alert] = t("alerts.error")
        format.html { render :edit }
        format.json { render json: @current_event.errors, status: :unprocessable_entity }
      end
    end
  end

  def remove_logo
    authorize @current_event
    @current_event.logo.destroy
    flash[:notice] = t("alerts.destroyed")
    redirect_to admins_event_path(@current_event)
  end

  def remove_background
    authorize @current_event
    @current_event.background.destroy
    flash[:notice] = t("alerts.destroyed")
    redirect_to admins_event_path(@current_event)
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
