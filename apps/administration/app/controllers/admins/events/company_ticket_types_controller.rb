class Admins::Events::CompanyTicketTypesController < Admins::Events::BaseController
  def index
    set_presenter
  end

  def new
    @company_ticket_type = CompanyTicketType.new
    @credential_types_collection =
      @fetcher.credential_types.includes(:catalog_item,
                                         company_ticket_types: [company_event_agreement: :company])
    @company_event_agreement_collection = @fetcher.company_event_agreements
  end

  def create
    @company_ticket_type = CompanyTicketType.new(permitted_params)
    @credential_types_collection =
      @fetcher.credential_types.includes(:catalog_item,
                                         company_ticket_types: [company_event_agreement: :company])
    @company_event_agreement_collection = @fetcher.company_event_agreements
    if @company_ticket_type.save
      redirect_to admins_event_company_ticket_types_url, notice: I18n.t("alerts.created")
    else
      flash.now[:error] = @company_ticket_type.errors.full_messages.join(". ")
      render :new
    end
  end

  def edit
    @company_ticket_type =
      @fetcher.company_ticket_types.includes(company_event_agreement: [:company]).find(params[:id])
    @credential_types_collection = @fetcher.credential_types
    @company_event_agreement_collection = @fetcher.company_event_agreements
  end

  def update # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    @company_ticket_type = @fetcher.company_ticket_types.find(params[:id])
    credential_type_id = @company_ticket_type.credential_type_id

    if @company_ticket_type.update(permitted_params)
      if credential_type_id.blank?
        tickets = @company_ticket_type.tickets
                                      .joins(:credential_assignments)
                                      .where(credential_assignments: { aasm_state: "assigned" })
        tickets.each do |ticket|
          CreditWriter.reassign_ticket(ticket, :assign) if ticket.credits.present?
          CustomerOrderTicketCreator.new.save(ticket)
        end
      end
      redirect_to admins_event_company_ticket_types_url, notice: I18n.t("alerts.updated")
    else
      @credential_types_collection = @fetcher.credential_types
      @company_event_agreement_collection = @fetcher.company_event_agreements

      flash.now[:error] = @company_ticket_type.errors.full_messages.join(". ")
      render :edit
    end
  end

  def destroy
    @company_ticket_type = @fetcher.company_ticket_types.find(params[:id])
    if @company_ticket_type.destroy
      flash[:notice] = I18n.t("alerts.destroyed")
    else
      flash[:error] = I18n.t("errors.messages.ticket_type_has_tickets")
    end
    redirect_to admins_event_company_ticket_types_url
  end

  def visibility
    @ctt = @fetcher.company_ticket_types.find(params[:company_ticket_type_id])
    @ctt.hidden? ? @ctt.show! : @ctt.hide!
    redirect_to admins_event_company_ticket_types_path(current_event), notice: I18n.t("alerts.updated")
  end

  private

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "CompanyTicketType".constantize.model_name,
      fetcher: @fetcher.company_ticket_types,
      search_query: params[:q],
      page: params[:page],
      context: view_context,
      include_for_all_items: [:credential_type, credential_type: :catalog_item]
    )
  end

  def permitted_params
    params.require(:company_ticket_type).permit(
      :event_id,
      :company_id,
      :name,
      :company_code,
      :credential_type_id,
      :company_event_agreement_id
    )
  end
end
