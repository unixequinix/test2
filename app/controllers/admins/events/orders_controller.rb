class Admins::Events::OrdersController < Admins::Events::BaseController
  def index
    set_presenter
  end

  def search
    index
    render :index
  end

  def show
    @order = current_event.orders.includes(catalog_items: :event).find(params[:id])
  end

  private

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "Order".constantize.model_name,
      fetcher: current_event.orders,
      search_query: params[:q],
      page: params[:page],
      include_for_all_items:
        [:profile, profile: :customer],
      context: view_context
    )
  end
end
