class Admins::Events::AccessTransactionsController < Admins::Events::BaseController
  def index
    set_presenter
  end

  def show
    @transaction = AccessTransaction.find(params[:id])
  end

  private

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "AccessTransaction".constantize.model_name,
      fetcher: AccessTransaction.where(event: current_event).order(id: :desc),
      search_query: params[:q],
      page: params[:page],
      include_for_all_items: [:customer_event_profile, :station],
      context: view_context
    )
  end
end
