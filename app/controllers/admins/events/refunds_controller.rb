class Admins::Events::RefundsController < Admins::Events::BaseController
  def index
    respond_to do |format|
      format.html do
        set_refunds
      end
      format.csv do
        refunds = Refund.query_for_csv(@current_event)
        redirect_to(admins_event_refunds_path(@current_event)) && return if refunds.empty?

        send_data(CsvExporter.to_csv(refunds))
      end
    end
  end

  def search
    set_refunds
    render :index
  end

  def show
    @refund = @current_event.refunds.find(params[:id])
  end

  private

  def set_refunds
    @q = @current_event.refunds.search(params[:q])
    @refunds = @q.result.page(params[:page])
  end

  def permitted_params
    params.require(:refund).permit(:state)
  end
end
