class Admins::Events::StationsController < Admins::Events::BaseController
  def index
    @group = params[:group]
    @stations = current_event.stations.where(group: @group)
  end

  def new
    @station = Station.new(group: params[:group])
    @group = @station.group
  end

  def create
    @station = Station.new(permitted_params)
    if @station.save
      path = admins_event_stations_url(current_event, group: @station.group)
      redirect_to path, notice: I18n.t("alerts.created")
    else
      flash.now[:error] = @station.errors.full_messages.join(". ")
      render :new
    end
  end

  def edit
    @station = current_event.stations.find(params[:id])
    @group = @station.group
  end

  def update
    @station = current_event.stations.find(params[:id])
    @group = @station.group

    if @station.update(permitted_params)
      path = admins_event_stations_url(current_event, group: @group)
      redirect_to path, notice: I18n.t("alerts.updated")
    else
      flash.now[:error] = @station.errors.full_messages.join(". ")
      render :edit
    end
  end

  def destroy
    @station = current_event.stations.find(params[:id])
    @station.destroy
    path = admins_event_stations_url(current_event, group: @station.group)
    redirect_to path, notice: I18n.t("alerts.destroyed")
  end

  private

  def permitted_params
    params.require(:station).permit(:name, :location, :event_id, :category, :group)
  end
end
