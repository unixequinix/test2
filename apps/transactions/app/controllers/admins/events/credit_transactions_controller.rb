class Admins::Events::CreditTransactionsController < Admins::Events::BaseController
  def index
    set_presenter
  end

  def show
    @transaction = CreditTransaction.find(params[:id])
  end

  private

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "CreditTransaction".constantize.model_name,
      fetcher: CreditTransaction.where(event: current_event).order(id: :desc),
      search_query: params[:q],
      page: params[:page],
      context: view_context
    )
  end
end
