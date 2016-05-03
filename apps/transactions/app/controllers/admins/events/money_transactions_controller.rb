class Admins::Events::MoneyTransactionsController < Admins::Events::BaseController
  def index
    set_presenter
  end

  def show
    @transaction = MoneyTransaction.find(params[:id])
  end

  private

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "MoneyTransaction".constantize.model_name,
      fetcher: MoneyTransaction.where(event: current_event).order(device_created_at: :desc),
      search_query: params[:q],
      page: params[:page],
      include_for_all_items: [:profile, :station],
      context: view_context
    )
  end
end
