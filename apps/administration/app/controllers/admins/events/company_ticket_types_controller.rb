class Admins::Events::CompanyTicketTypesController < Admins::Events::BaseController
  def index
    set_presenter
  end

  def new
    @company_ticket_type = CompanyTicketType.new
    @preevent_products_collection = @fetcher.preevent_products
    @companies_collection = @fetcher.companies
  end

  def create
    @company_ticket_type = CompanyTicketType.new(permitted_params)
    @preevent_products_collection = @fetcher.preevent_products
    @companies_collection = @fetcher.companies
    if @company_ticket_type.save
      redirect_to admins_event_company_ticket_types_url, notice: I18n.t("alerts.created")
    else
      flash.now[:error] = @company_ticket_type.errors.full_messages.join(". ")
      render :new
    end
  end

  def edit
    @company_ticket_type = @fetcher.company_ticket_types.find(params[:id])
    @preevent_products_collection = @fetcher.preevent_products
    @companies_collection = @fetcher.companies
  end

  def update
    @company_ticket_type = @fetcher.company_ticket_types.find(params[:id])
    @preevent_products_collection = @fetcher.preevent_products
    @companies_collection = @fetcher.companies
    if @company_ticket_type.update(permitted_params)
      redirect_to admins_event_company_ticket_types_url, notice: I18n.t("alerts.updated")
    else
      flash.now[:error] = @company_ticket_type.errors.full_messages.join(". ")
      render :edit
    end
  end

  def destroy
    @company_ticket_type = @fetcher.company_ticket_types.find(params[:id])
    @company_ticket_type.destroy!
    flash[:notice] = I18n.t("alerts.destroyed")
    redirect_to admins_event_company_ticket_types_url
  end

  private

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "CompanyTicketType".constantize.model_name,
      fetcher: @fetcher.company_ticket_types,
      search_query: params[:q],
      page: params[:page],
      context: view_context,
      include_for_all_items: [:company]
    )
  end

  def permitted_params
    params.require(:company_ticket_type).permit(
      :event_id,
      :company_id,
      :name,
      :company_ticket_type_ref,
      :preevent_product_id
    )
  end
end
