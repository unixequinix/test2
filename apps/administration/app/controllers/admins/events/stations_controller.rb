class Admins::Events::StationsController < Admins::Events::BaseController
  before_action :set_station, only: [:edit, :update, :destroy, :visibility]
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

  def update
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

  def clone
    @station = Station.find(params[:station_id])
    path = admins_event_stations_url(current_event, group: @station.group)
    station_clone = @station.deep_clone(include: { station_parameters: :station_parametable }, validate: false)
    if station_clone.update(name: @station.name + Time.now.to_i.to_s)
      flash[:notice] = I18n.t("alerts.cloned")
    else
      flash[:error] = I18n.t("errors.messages.station_has_associations")
    end
    redirect_to(path)
  end

  def destroy
    path = admins_event_stations_url(current_event, group: @station.group)
    if @station.destroy
      flash[:notice] = I18n.t("alerts.destroyed")
    else
      flash[:error] = I18n.t("errors.messages.station_has_associations")
    end
    redirect_to(path)
  end

  def sort
    params[:order].each do |_key, value|
      @fetcher.stations.find(value[:id]).update_attribute(:position, value[:position])
    end
    render nothing: true
  end

  def visibility
    @station.update(hidden: !@station.hidden?)
    @group = @station.group
    redirect_to admins_event_stations_url(current_event, group: @group), notice: I18n.t("alerts.updated")
  end

  private

  def set_station
    id = params[:id] || params[:station_id]
    @station = current_event.stations.find(id)
  end

  def permitted_params
    params.require(:station).permit(:name, :location, :event_id, :category, :group, :reporting_category,
                                    :address, :registration_num, :official_name)
  end
end
