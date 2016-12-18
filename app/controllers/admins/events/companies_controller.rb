class Admins::Events::CompaniesController < Admins::Events::BaseController
  before_action :set_company, only: [:edit, :update, :destroy]

  def index
    set_presenter
  end

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(permitted_params)
    if @company.save
      flash[:notice] = I18n.t("alerts.created")
      redirect_to admins_event_companies_url
    else
      flash[:error] = @company.errors.full_messages.join(". ")
      render :new
    end
  end

  def update
    if @company.update(permitted_params)
      flash[:notice] = I18n.t("alerts.updated")
      redirect_to admins_event_companies_url
    else
      flash[:error] = @company.errors.full_messages.join(". ")
      render :edit
    end
  end

  def destroy
    if @company.destroy
      flash[:notice] = I18n.t("alerts.destroyed")
      redirect_to admins_event_companies_url
    else
      flash.now[:error] = I18n.t("errors.messages.ticket_type_dependent")
      set_presenter
      render :index
    end
  end

  private

  def set_company
    @company = @current_event.companies.find(params[:id])
  end

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "Company".constantize.model_name,
      fetcher: @current_event.companies,
      search_query: params[:q],
      page: params[:page],
      include_for_all_items: [],
      context: view_context
    )
  end

  def permitted_params
    params.require(:company).permit(:name, :event_id)
  end
end
