class Admins::Events::StationsController < Admins::Events::BaseController
  before_action :set_station, only: [:edit, :update, :destroy]
  def index
    @group = params[:group]
    @stations = current_event.stations.where(group: @group).order(name: :asc)
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
    @group = @station.group
  end

  def update # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    @group = @station.group

    respond_to do |format|
      if @station.update(permitted_params)
        format.html do
          path = admins_event_stations_url(current_event, group: @group)
          redirect_to path, notice: I18n.t("alerts.updated")
        end
        format.json { render json: @station }
      else
        format.html do
          flash.now[:error] = @station.errors.full_messages.join(". ")
          render :edit
        end
      end
    end
  end

  def destroy
    path = admins_event_stations_url(current_event, group: @station.group)
    if @station.destroy
      flash[:notice] = I18n.t("alerts.destroyed")
      redirect_to path
    else
      flash[:error] = I18n.t("errors.messages.station_has_associations")
      redirect_to path
    end
  end

  def sort
    params[:order].each do |_key, value|
      @fetcher.stations.find(value[:id]).update_attribute(:position, value[:position])
    end
    render nothing: true
  end

  private

  def set_station
    @station = current_event.stations.find(params[:id])
  end

  def permitted_params
    params.require(:station).permit(:name, :location, :event_id,
                                    :category, :group, :reporting_category)
  end
end
