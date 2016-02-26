class Admins::Events::SalesStationsController < Admins::Events::BaseController
  def index
    set_presenter
  end

  def show
    @station = @fetcher.sales_stations.find_by(id: params[:id])
  end

  def edit
    @station = @fetcher.sales_stations.find_by(id: params[:id])
  end

  def update
    @station = @fetcher.sales_stations.find(params[:id])
    if @station.update(permitted_params)
      flash[:notice] = I18n.t("alerts.updated")
      redirect_to admins_event_stations_url
    else
      flash.now[:error] = @station.errors.full_messages.join(". ")
      render :edit
    end
  end

  def destroy
    @station = @fetcher.sales_stations.find(params[:id])
    @station.destroy
    flash[:notice] = I18n.t("alerts.destroyed")
    redirect_to admins_event_stations_url
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

  def permitted_params
    params.require(:station).permit(:id, station_catalog_items_attributes: [
                                      :id,
                                      :price,
                                      :catalog_item_id,
                                      :_destroy,
                                      station_parameter_attributes: [ :id, :station_id ]
                                    ]
    )
  end
end
