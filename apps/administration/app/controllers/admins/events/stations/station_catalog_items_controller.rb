class Admins::Events::Stations::StationCatalogItemsController < Admins::Events::BaseController
  def index
    @station = @fetcher.sale_stations.find_by(id: params[:station_id])
    @catalog_items = @fetcher.catalog_items
    @station_catalog_item = StationCatalogItem.new
    set_presenter
  end

  def create
    @station = @fetcher.sale_stations.find_by(id: params[:station_id])
    @catalog_items = @fetcher.catalog_items
    @station_catalog_item = StationCatalogItem.new
    if @station_catalog_item.create(permitted_params)
      flash[:notice] = I18n.t("alerts.updated")
      redirect_to edit_admins_event_sales_station_url
    else
      flash.now[:error] = @station.errors.full_messages.join(". ")
      render :edit
    end
  end

  def destroy
    @station = @fetcher.sale_stations.find(params[:id])
    @station = @fetcher.station_catalog_item.find_by(id: params[:catalog_item_id])
    @station_catalog_item.destroy
    flash[:notice] = I18n.t("alerts.destroyed")
    redirect_to edit_admins_event_sales_station_url
  end

  private

  def permitted_params
    params.require(:station_catalog_item)
      .permit(:id, :price, :catalog_item_id, station_parameter_attributes: [:id, :station_id])
  end

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "StationCatalogItem".constantize.model_name,
      fetcher: @fetcher.station_catalog_items,
      search_query: params[:q],
      page: params[:page],
      include_for_all_items: [:catalog_item],
      context: view_context
    )
  end
end
