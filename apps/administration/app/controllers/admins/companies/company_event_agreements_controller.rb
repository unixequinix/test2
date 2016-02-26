class Admins::Companies::CompanyEventAgreementsController < Admins::BaseController

  def index
    @company = Company.find_by(id: params[:company_id])
    @agreements = @company.company_event_agreements.includes(:event).page(params[:page]).per(10)
    @agreement = CompanyEventAgreement.new
  end

  def create
    @company = Company.find_by(id: params[:company_id])
    @agreement = @company.company_event_agreements.create!(permitted_params)
  end

  def destroy
    @agreement = CompanyEventAgreement.find_by(id: params[:id])

    if @agreement.destroy
      flash[:notice] = I18n.t("alerts.destroyed")
      redirect_to admins_company_company_event_agreements_path(params[:company_id])
    else
      flash[:error] = @agreement.errors.full_messages.join(". ")
      redirect_to admins_company_company_event_agreements_path(params[:company_id])
    end
  end

  private

  def permitted_params
    params.require(:company_event_agreement).permit(:event_id)
  end
end
