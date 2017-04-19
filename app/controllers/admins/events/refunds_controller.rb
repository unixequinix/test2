class Admins::Events::RefundsController < Admins::Events::BaseController
  def index
    @refunds = @current_event.refunds.page(params[:page])
    authorize @refunds
    respond_to do |format|
      format.html
      format.csv { send_data(CsvExporter.to_csv(Refund.query_for_csv(@current_event))) }
    end
  end

  def show
    @refund = @current_event.refunds.find(params[:id])
    authorize @refund
  end

  def destroy
    skip_authorization # TODO: remove after loolla
    @refund = @current_event.refunds.find(params[:id])
    @refund.destroy
    redirect_to :back, notice: t('alerts.destroyed')
  end

  private

  def permitted_params
    params.require(:refund).permit(:state)
  end
end
