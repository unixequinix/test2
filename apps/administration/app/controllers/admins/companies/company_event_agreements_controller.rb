class Admins::Companies::CompanyEventAgreementsController < Admins::BaseController
  before_action :set_company

  def index
    @agreements = @company.company_event_agreements
                          .includes(:event)
                          .page(params[:page])
                          .per(10)
    @agreement = CompanyEventAgreement.new
  end

  def create
    @agreement = @company.company_event_agreements.create!(permitted_params)
  end

  def revoke_agreement
    @agreement = @company.company_event_agreements.find_by(id: params[:id])
    @agreement.revoke!
    redirect_to admins_company_company_event_agreements_path(@company)
  end

  def grant_agreement
    @agreement = @company.company_event_agreements.find_by(id: params[:id])
    @agreement.grant!
    redirect_to admins_company_company_event_agreements_path(@company)
  end

  private

  def set_company
    @company = Company.find_by(id: params[:company_id])
  end

  def permitted_params
    params.require(:company_event_agreement).permit(:event_id)
  end
end
