class Admins::Events::CompaniesTicketTypesController < Admins::Events::BaseController
  def index
    set_presenter
  end

  def new
    @companies_ticket_type = CompaniesTicketType.new
    @preevent_products_collection = @fetcher.preevent_products
  end

  def create
    @companies_ticket_type = CompaniesTicketType.new(permitted_params)
    if @companies_ticket_type.save
      flash[:notice] = I18n.t("alerts.created")
      redirect_to admins_event_companies_ticket_types_url
    else
      flash[:error] = @companies_ticket_type.errors.full_messages.join(". ")
      render :new
    end
  end

  def edit
    @companies_ticket_type = @fetcher.companies_ticket_types.find(params[:id])
    @preevent_products_collection = @fetcher.preevent_products
  end

  def update
    @companies_ticket_type = @fetcher.companies_ticket_types.find(params[:id])
    if @companies_ticket_type.update(permitted_params)
      flash[:notice] = I18n.t("alerts.updated")
      redirect_to admins_event_companies_ticket_types_url
    else
      flash[:error] = @companies_ticket_type.errors.full_messages.join(". ")
      render :edit
    end
  end

  def destroy
    @companies_ticket_type = @fetcher.companies_ticket_types.find(params[:id])
    @companies_ticket_type.destroy!
    flash[:notice] = I18n.t("alerts.destroyed")
    redirect_to admins_event_companies_ticket_types_url
  end

  private

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "CompaniesTicketType".constantize.model_name,
      fetcher: @fetcher.companies_ticket_types,
      search_query: params[:q],
      page: params[:page],
      context: view_context,
      include_for_all_items: []
    )
  end

  def permitted_params
    params.require(:companies_ticket_type).permit(
      :event_id,
      :name,
      :company,
      preevent_product_ids: []
    )
  end
end
