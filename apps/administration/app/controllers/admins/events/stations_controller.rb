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

  def update # rubocop:disable Metrics/AbcSize
    @station = current_event.stations.find(params[:id])
    @group = @station.group

    respond_to do |format|
      if @station.update(permitted_params)
        format.html do
          redirect_to admins_event_stations_url(current_event, group: @group), notice: I18n.t("alerts.updated")
        end
      else
        format.html do
          flash.now[:error] = @station.errors.full_messages.join(". ")
          render :edit
        end
      end
      format.json { render json: @station }
    end
  end

  def destroy
    @station = current_event.stations.find(params[:id])
    path = admins_event_stations_url(current_event, group: @station.group)
    redirect_to(path, notice: I18n.t("alerts.destroyed")) && return if @station.destroy
    redirect_to(path, error: I18n.t("errors.messages.station_dependent"))
  end

  def sort
    params[:order].each do |_key, value|
      @fetcher.stations.find(value[:id]).update_attribute(:position, value[:position])
    end
    render nothing: true
  end

  private

  def permitted_params
    params.require(:station).permit(:name, :location, :event_id, :category, :group)
  end
end
