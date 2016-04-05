class Admins::Events::OrderTransactionsController < Admins::Events::BaseController
  def index
    set_presenter
  end

  def show
    @transaction = OrderTransaction.find(params[:id])
  end

  private

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "OrderTransaction".constantize.model_name,
      fetcher: OrderTransaction.where(event: current_event),
      search_query: params[:q],
      page: params[:page],
      context: view_context
    )
  end
end
