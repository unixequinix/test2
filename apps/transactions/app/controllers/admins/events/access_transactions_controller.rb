class Admins::Events::AccessTransactionsController < Admins::Events::BaseController
  def index
    set_presenter
  end

  private

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "AccessTransaction".constantize.model_name,
      fetcher: AccessTransaction.where(event: current_event),
      search_query: params[:q],
      page: params[:page],
      context: view_context
    )
  end
end
