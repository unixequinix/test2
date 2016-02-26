class Admins::Events::StationsController < Admins::Events::BaseController
  def index
    set_presenter
  end

  def new
    @station = Station.new
  end

  def create
    @station = Station.new(permitted_params)
    if @station.save
      flash[:notice] = I18n.t("alerts.created")
      redirect_to admins_event_stations_url
    else
      flash.now[:error] = @station.errors.full_messages.join(". ")
      render :new
    end
  end

  def edit
    @station = @fetcher.stations.find(params[:id])
  end

  def update
    @station = @fetcher.stations.find(params[:id])
    if @station.update(permitted_params)
      flash[:notice] = I18n.t("alerts.updated")
      redirect_to admins_event_stations_url
    else
      flash.now[:error] = @station.errors.full_messages.join(". ")
      render :edit
    end
  end

  def destroy
    @station = @fetcher.stations.find(params[:id])
    @station.destroy
    flash[:notice] = I18n.t("alerts.destroyed")
    redirect_to admins_event_stations_url
  end

  private

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "Station".constantize.model_name,
      fetcher: @fetcher.stations,
      search_query: params[:q],
      page: params[:page],
      include_for_all_items: [station_type: [:station_group]],
      context: view_context
    )
  end

  def permitted_params
    params.require(:station).permit(:name, :event_id, :station_type_id)
  end
end
