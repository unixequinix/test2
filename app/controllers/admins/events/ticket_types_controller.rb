class Admins::Events::TicketTypesController < Admins::Events::BaseController
  def index
    set_presenter
  end

  def new
    @ticket_type = TicketType.new
    @catalog_items = current_event.catalog_items.includes(ticket_types: [company_event_agreement: :company])
    @company_event_agreement_collection = current_event.company_event_agreements
  end

  def create
    @ticket_type = TicketType.new(permitted_params)
    @catalog_items = current_event.catalog_items.includes(ticket_types: [company_event_agreement: :company])
    @company_event_agreement_collection = current_event.company_event_agreements

    if @ticket_type.save
      redirect_to admins_event_ticket_types_url, notice: I18n.t("alerts.created")
    else
      flash.now[:error] = @ticket_type.errors.full_messages.join(". ")
      render :new
    end
  end

  def edit
    @ticket_type = current_event.ticket_types.find(params[:id])
    @catalog_items = current_event.catalog_items
    @company_event_agreement_collection = current_event.company_event_agreements
  end

  def update
    @ticket_type = current_event.ticket_types.find(params[:id])

    if @ticket_type.update(permitted_params)
      redirect_to admins_event_ticket_types_url, notice: I18n.t("alerts.updated")
    else
      @catalog_items = current_event.catalog_items
      @company_event_agreement_collection = current_event.company_event_agreements

      flash.now[:error] = @ticket_type.errors.full_messages.join(". ")
      render :edit
    end
  end

  def destroy
    @ticket_type = current_event.ticket_types.find(params[:id])

    if @ticket_type.destroy
      flash[:notice] = I18n.t("alerts.destroyed")
    else
      flash[:error] = I18n.t("errors.messages.ticket_type_has_tickets")
    end

    redirect_to admins_event_ticket_types_url
  end

  def visibility
    @ctt = current_event.ticket_types.find(params[:ticket_type_id])
    @ctt.hidden? ? @ctt.show! : @ctt.hide!
    redirect_to admins_event_ticket_types_path(current_event), notice: I18n.t("alerts.updated")
  end

  private

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "TicketType".constantize.model_name,
      fetcher: current_event.ticket_types,
      search_query: params[:q],
      page: params[:page],
      context: view_context,
      include_for_all_items: [:catalog_item]
    )
  end

  def permitted_params
    params.require(:ticket_type).permit(:event_id, :company_id, :name, :company_code, :company_event_agreement_id, :catalog_item_id) # rubocop:disable Metrics/LineLength
  end
end
