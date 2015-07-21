class Admins::ClaimsController < Admins::BaseController

  def index
    @q = Claim.search(params[:q])
    @claims = @q.result(distinct: true).page(params[:page]).includes(:customer)
  end

  def search
    index
    render :index
  end

  def show
    @claim = Claim.includes(claim_parameters: :parameter).find(params[:id])
  end

  def update
    @claim = Claim.find(params[:id])
    if @claim.update(permitted_params)
      flash[:notice] = I18n.t('alerts.updated')
      redirect_to admins_customer_url(@claim.customer)
    else
      flash[:error] = @claim.errors.full_messages.join(". ")
      redirect_to admins_customer_url(@claim.customer)
    end
  end

  private

  def permitted_params
    params.require(:claim).permit(:aasm_state)
  end
end
