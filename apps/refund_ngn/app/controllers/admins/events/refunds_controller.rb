class Admins::Events::RefundsController < Admins::Events::RefundsBaseController

  def index
    @q = @fetcher.refunds.search(params[:q])
    @refunds = @q.result(distinct: true).page(params[:page]).includes(:claim, claim: [:customer_event_profile, customer_event_profile: :customer])
    respond_to do |format|
      format.html
      format.csv { send_data Csv::CsvExporter.to_csv(Refund.selected_data(current_event.id)) }
    end
  end

  def search
    @q = @fetcher.refunds.search(params[:q])
    @refunds = @q.result(distinct: true).page(params[:page]).includes(:claim, claim: [:customer_event_profile, customer_event_profile: :customer])
    render :index
  end

  def show
    @refund = @fetcher.refunds.find(params[:id])
  end

  def update
    @refund = @fetcher.refunds.find(params[:id])
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
