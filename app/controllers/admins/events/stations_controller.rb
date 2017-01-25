class Admins::Events::StationsController < Admins::Events::BaseController
  before_action :set_station, except: [:index, :new, :create]

  def index
    @group = params[:group]
    @stations = @current_event.stations.where(group: @group).order("hidden ASC, name ASC")
  end

  def new
    @station = Station.new(group: params[:group])
    @group = @station.group
  end

  def create
    @station = Station.new(permitted_params)
    @group = @station.group
    if @station.save
      path = admins_event_stations_url(@current_event, group: @station.group)
      redirect_to path, notice: I18n.t("alerts.created")
    else
      flash.now[:error] = I18n.t("alerts.error")
      render :new
    end
  end

  def update
    respond_to do |format|
      if @station.update(permitted_params)
        format.html { redirect_to admins_event_stations_url(@current_event, group: @group), notice: I18n.t("alerts.updated") }
        format.json { render json: @station }
      else
        format.html do
          flash.now[:error] = I18n.t("alerts.error")
          render :edit
        end
      end
    end
  end

  def clone
    @station = @station.deep_clone(include: [:station_catalog_items, :station_products, :topup_credits, :access_control_gates], validate: false)
    render :new
  end

  def destroy
    @station.destroy
    redirect_to admins_event_stations_url(@current_event, group: @station.group), notice: I18n.t("alerts.destroyed")
  end

  def sort
    params[:order].each do |_key, value|
      @current_event.stations.find(value[:id]).update_attribute(:position, value[:position])
    end
    render nothing: true
  end

  def visibility
    @station.update(hidden: !@station.hidden?)
    redirect_to admins_event_stations_url(@current_event, group: @group), notice: I18n.t("alerts.updated")
  end

  private

  def set_station
    id = params[:id] || params[:station_id]
    @station = @current_event.stations.find(id)
    @group = @station.group
  end

  def permitted_params
    params.require(:station).permit(:name, :location, :event_id, :category, :group, :reporting_category, :address, :registration_num, :official_name)
  end
end
