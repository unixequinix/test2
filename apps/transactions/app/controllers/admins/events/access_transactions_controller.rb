class Admins::Events::AccessTransactionsController < Admins::Events::BaseController
  before_filter :set_presenter, only: [:index, :search]

  def search
    render :index
  end

  def show
    @transaction = AccessTransaction.find(params[:id])
  end

  private

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "AccessTransaction".constantize.model_name,
      fetcher: AccessTransaction.where(event: current_event).order(device_created_at: :desc),
      search_query: params[:q],
      page: params[:page],
      include_for_all_items: [:profile, :station],
      context: view_context
    )
  end
end
