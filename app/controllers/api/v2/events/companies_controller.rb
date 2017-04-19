class Api::V2::Events::CompaniesController < Api::V2::BaseController
  before_action :set_company, only: %i[show update destroy]

  # GET /companies
  def index
    @companies = @current_event.companies
    authorize @companies

    render json: @companies
  end

  # GET /companies/1
  def show
    render json: @company
  end

  # POST /companies
  def create
    @company = @current_event.companies.new(company_params)
    authorize @company

    if @company.save
      render json: @company, status: :created, location: @company
    else
      render json: @company.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /companies/1
  def update
    if @company.update(company_params)
      render json: @company
    else
      render json: @company.errors, status: :unprocessable_entity
    end
  end

  # DELETE /companies/1
  def destroy
    @company.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_company
    @company = @current_event.companies.find(params[:id])
    authorize @company
  end

  # Only allow a trusted parameter "white list" through.
  def company_params
    params.require(:company).permit(:name, :access_token)
  end
end
