class Admins::Events::Stations::StationProductsController < Admins::Events::BaseController
  def index
    @station = @fetcher.point_of_sale_stations.find_by(id: params[:station_id])
    @products = @fetcher.unassigned_products(@station)
    @station_product = StationProduct.new
    set_presenter
  end

  def create
    @station = @fetcher.point_of_sale_stations.find_by(id: params[:station_id])
    @products = @fetcher.unassigned_products(@station)
    @station_product = StationProduct.create!(permitted_params)
  end

  def update
    @product = @fetcher.station_products.find(params[:id])
    @product.update_attributes!(permitted_params)
    render json: @product
  end

  def destroy
    @station = @fetcher.point_of_sale_stations.find(params[:station_id])
    @products = @station.unassigned_products
    @station_product = @fetcher.station_products.find(params[:id])
    @station_product.destroy
    flash[:notice] = I18n.t("alerts.destroyed")
    redirect_to admins_event_station_station_products_url(current_event, @station)
  end

  private

  def permitted_params
    params.require(:station_product)
          .permit(:id, :price, :product_id, station_parameter_attributes: [:id, :station_id])
  end

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "StationProduct".constantize.model_name,
      fetcher: @fetcher.station_products.joins(:station_parameter)
               .where(station_parameters: { station_id: params[:station_id] }),
      search_query: params[:q],
      page: params[:page],
      include_for_all_items: [:product],
      context: view_context
    )
  end
end
