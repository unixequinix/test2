class Admins::Events::CreditTransactionsController < Admins::Events::BaseController
  before_filter :set_presenter, only: [:index, :search]

  def index
  end

  def search
    render :index
  end

  def show
    @transaction = CreditTransaction.find(params[:id])
  end

  private

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "CreditTransaction".constantize.model_name,
      fetcher: CreditTransaction.where(event: current_event).order(device_created_at: :desc),
      search_query: params[:q],
      page: params[:page],
      include_for_all_items: [:customer_event_profile, :station],
      context: view_context
    )
  end
end
