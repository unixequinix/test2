class Admins::Events::RefundsController < Admins::Events::RefundsBaseController
  before_filter :set_presenter, only: [:index, :search]

  def index
    respond_to do |format|
      format.html
      format.csv { send_data Csv::CsvExporter.to_csv(Refund.selected_data(current_event.id)) }
    end
  end

  def search
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

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: 'Refund'.constantize.model_name,
      fetcher: @fetcher.refunds,
      search_query: params[:q],
      page: params[:page],
      context: view_context,
      include_for_all_items: [:claim, claim: [:customer_event_profile, customer_event_profile: :customer]]
    )
  end

  def permitted_params
    params.require(:refund).permit(:aasm_state)
  end
end
