class Admins::Events::CompaniesController < Admins::Events::BaseController
  before_action :set_company, except: [:index, :new, :create]

  def index
    @companies = @current_event.companies
    authorize @companies
    @companies = @companies.page(params[:page])
  end

  def new
    @company = Company.new
    authorize @company
  end

  def create
    @company = Company.new(permitted_params)
    authorize @company
    if @company.save
      flash[:notice] = t("alerts.created")
      redirect_to admins_event_companies_path
    else
      flash[:error] = @company.errors.full_messages.join(". ")
      render :new
    end
  end

  def update
    if @company.update(permitted_params)
      flash[:notice] = t("alerts.updated")
      redirect_to admins_event_companies_path
    else
      flash[:error] = @company.errors.full_messages.join(". ")
      render :edit
    end
  end

  def destroy
    if @company.destroy
      flash[:notice] = t("alerts.destroyed")
      redirect_to admins_event_companies_path
    else
      flash.now[:error] = t("errors.messages.ticket_type_dependent")
      @companies = @current_event.companies.page
      render :index
    end
  end

  private

  def set_company
    @company = @current_event.companies.find(params[:id])
    authorize @company
  end

  def permitted_params
    params.require(:company).permit(:name, :event_id)
  end
end
