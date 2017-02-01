class Admins::CompaniesController < Admins::BaseController
  before_action :set_company, only: [:show, :edit, :update, :destroy]

  def index
    @companies = Company.all.page(params[:page])
  end

  def new
    @company = Company.new
  end

  def show
    @agreements = @company.company_event_agreements
  end

  def create
    @company = Company.new(permitted_params)
    if @company.save
      flash[:notice] = t("alerts.created")
      redirect_to admins_companies_path
    else
      render :new
    end
  end

  def edit; end

  def update
    if @company.update(permitted_params)
      flash[:notice] = t("alerts.updated")
      redirect_to admins_companies_path
    else
      render :edit
    end
  end

  def destroy
    if @company.destroy
      flash[:notice] = t("alerts.destroyed")
    else
      flash[:error] = @company.errors.full_messages.join(". ")
    end
    redirect_to admins_companies_path
  end

  private

  def set_company
    @company = Company.find_by(id: params[:id])
  end

  def permitted_params
    params.require(:company).permit(:name)
  end
end
