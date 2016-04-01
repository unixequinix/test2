class Admins::Events::CredentialTransactionsController < Admins::Events::BaseController
  def index
    set_presenter
  end

  private

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "CredentialTransaction".constantize.model_name,
      fetcher: CredentialTransaction.where(event: current_event),
      search_query: params[:q],
      page: params[:page],
      context: view_context
    )
  end
end
