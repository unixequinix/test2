class Admins::Events::CustomerOrdersController < Admins::Events::PaymentsBaseController
  def index
    set_presenter
  end

  def search
    index
    render :index
  end

  private

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "CustomerOrder".constantize.model_name,
      fetcher: @fetcher.customer_orders,
      search_query: params[:q],
      page: params[:page],
      include_for_all_items:
        [:preevent_product, :customer_event_profile, customer_event_profile: :customer],
      context: view_context
    )
  end
end
