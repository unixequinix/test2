class Admins::Events::OrdersController < Admins::Events::PaymentsBaseController
  def index
    set_presenter
  end

  def search
    index
    render :index
  end

  def show
    @order = @fetcher.orders.find(params[:id])
  end

  private

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "Order".constantize.model_name,
      fetcher: @fetcher.orders,
      search_query: params[:q],
      page: params[:page],
      include_for_all_items:
        [:customer_event_profile, customer_event_profile: :customer],
      context: view_context
    )
  end
end
