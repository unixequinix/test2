class Admins::Events::StationsController < Admins::Events::BaseController
  before_action :set_station, except: [:index, :new, :create]

  def index
    @group = params[:group]
    @stations = @current_event.stations.where(group: @group).order(hidden: :asc, name: :asc)
    authorize @stations
  end

  def new
    @station = Station.new(group: params[:group])
    authorize @station
    @group = @station.group
  end

  def create
    @station = Station.new(permitted_params)
    authorize @station
    @group = @station.group
    if @station.save
      path = admins_event_stations_path(@current_event, group: @station.group)
      redirect_to path, notice: t("alerts.created")
    else
      flash.now[:alert] = t("alerts.error")
      render :new
    end
  end

  def update
    respond_to do |format|
      if @station.update(permitted_params)
        format.html { redirect_to admins_event_stations_path(@current_event, group: @group), notice: t("alerts.updated") }
        format.json { render json: @station }
      else
        format.html do
          flash.now[:alert] = t("alerts.error")
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
    if @station.destroy
      flash[:notice] = t("alerts.destroyed")
    else
      flash[:error] = @pack.errors.full_messages.to_sentence
    end

    redirect_to admins_event_stations_path(@current_event, group: @station.group)
  end

  def sort
    params[:order].each { |_key, value| @current_event.stations.find(value[:id]).update_attribute(:position, value[:position]) }
    render nothing: true
  end

  def visibility
    @station.update(hidden: !@station.hidden?)
    redirect_to admins_event_stations_path(@current_event, group: @group), notice: t("alerts.updated")
  end

  private

  def set_station
    id = params[:id] || params[:station_id]
    @station = @current_event.stations.find(id)
    authorize @station
    @group = @station.group
  end

  def permitted_params
    params.require(:station).permit(:name, :location, :event_id, :category, :group, :reporting_category, :address, :registration_num, :official_name)
  end
end
