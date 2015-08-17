class Admins::RefundsController < Admins::BaseController

  def index
    @q = Refund.search(params[:q])
    @refunds = @q.result(distinct: true).page(params[:page]).includes(:claim, claim: :customer)
    respond_to do |format|
      format.html
      format.csv { send_data Refund.all.to_csv }
    end
  end

  def search
    @q = Refund.search(params[:q])
    @refunds = @q.result(distinct: true).page(params[:page]).includes(:claim, claim: :customer)
    render :index
  end

  def show
    @refund = Refund.find(params[:id])
  end

  def update
    @refund = Refund.find(params[:id])
    if @refund.update(permitted_params)
      flash[:notice] = I18n.t('alerts.updated')
      redirect_to admins_refund_url(@refund)
    else
      flash[:error] = I18n.t('alerts.error')
      redirect_to admins_refund_url(@refund)
    end
  end

  private

  def permitted_params
    params.require(:refund).permit(:aasm_state)
  end

end
