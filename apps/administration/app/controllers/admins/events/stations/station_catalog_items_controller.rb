class Admins::Events::Stations::StationCatalogItemsController < Admins::Events::BaseController
  def index
    @station = @fetcher.stations.find_by(id: params[:station_id])
    @catalog_items = @fetcher.unassigned_catalog_items(@station)
    @station_catalog_item = StationCatalogItem.new
    set_presenter
  end

  def create
    @station = @fetcher.stations.find_by(id: params[:station_id])
    @catalog_items = @fetcher.unassigned_catalog_items(@station)
    @station_catalog_item = StationCatalogItem.create!(permitted_params)
  end

  def destroy
    @station = @fetcher.accreditation_stations.find(params[:station_id])
    @catalog_items = @station.unassigned_catalog_items
    @station_catalog_item = @fetcher.station_catalog_items.find(params[:id])
    @station_catalog_item.destroy
    flash[:notice] = I18n.t("alerts.destroyed")
    redirect_to admins_event_station_station_catalog_items_url(current_event, @station)
  end

  private

  def permitted_params
    params.require(:station_catalog_item)
          .permit(:id, :price, :catalog_item_id, station_parameter_attributes: [:id, :station_id])
  end

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "StationCatalogItem".constantize.model_name,
      fetcher: @fetcher.station_catalog_items.joins(:station_parameter)
               .where(station_parameters: { station_id: params[:station_id] }),
      search_query: params[:q],
      page: params[:page],
      include_for_all_items: [:catalog_item],
      context: view_context
    )
  end
end
