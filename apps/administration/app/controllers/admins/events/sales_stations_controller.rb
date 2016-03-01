class Admins::Events::SalesStationsController < Admins::Events::BaseController
  def index
    set_presenter
  end

  private

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "Station".constantize.model_name,
      fetcher: @fetcher.sales_stations,
      search_query: params[:q],
      page: params[:page],
      include_for_all_items: [],
      context: view_context
    )
  end
end
