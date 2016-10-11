class Admins::Events::RefundsController < Admins::Events::BaseController
  before_action :set_presenter, only: [:index, :search]

  def index
    respond_to do |format|
      format.html
      format.csv do
        refunds = Refund.query_for_csv(current_event)
        redirect_to(admins_event_refunds_path(current_event)) && return if refunds.empty?

        send_data(Csv::CsvExporter.to_csv(refunds))
      end
    end
  end

  def search
    render :index
  end

  def show
    @refund = current_event.refunds.find(params[:id])
  end

  def update
    refund = current_event.refunds.find(params[:id])
    if refund.update(permitted_params)
      flash[:notice] = I18n.t("alerts.updated")
    else
      flash[:error] = I18n.t("alerts.error")
    end
    redirect_to admins_refund_url(refund)
  end

  private

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "Refund".constantize.model_name,
      fetcher: current_event.refunds,
      search_query: params[:q],
      page: params[:page],
      context: view_context,
      include_for_all_items: [:claim, claim: [:profile, profile: :customer]]
    )
  end

  def permitted_params
    params.require(:refund).permit(:aasm_state)
  end
end
