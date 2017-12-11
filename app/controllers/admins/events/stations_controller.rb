class Admins::Events::StationsController < Admins::Events::BaseController
  before_action :set_station, except: %i[index new create]

  def index
    @group = params[:group]&.to_sym
    q = @current_event.stations
    q = @group.blank? ? q.all : q.where(category: Station::GROUPS[@group])
    q = q.order(hidden: :asc, name: :asc)

    @q = q.ransack(params[:q])
    @stations = @q.result
    authorize @stations
  end

  def show
    authorize @station
    @items = @station.all_station_items
    @items.sort_by! { |i| i.class.sort_column.to_s } if @items.first
    @transactions = @current_event.transactions.where(station: @station).status_ok.credit
    @sales = @transactions.credit.where(action: "sale").sum(:credits).abs
    @refunds = @transactions.credit.where(action: "sale_refund").sum(:credits).abs
    @operators = @transactions.pluck(:operator_tag_uid).uniq.count
    @devices = @current_event.devices.where(mac: @transactions.pluck(:device_uid).uniq)
  end

  def new
    @station = @current_event.stations.new
    authorize @station
    @group = params[:group]
  end

  def create
    @station = @current_event.stations.new(permitted_params)
    authorize @station
    @group = @station.group
    if @station.save
      redirect_to admins_event_station_path(@current_event, @station), notice: t("alerts.created")
    else
      flash.now[:alert] = t("alerts.error")
      render :new
    end
  end

  def hide
    @station.update!(hidden: true)
    respond_to do |format|
      format.html { redirect_to admins_event_station_path(@current_event, @station), notice: t("alerts.updated") }
      format.json { render json: @station }
    end
  end

  def unhide
    @station.update!(hidden: false)
    respond_to do |format|
      format.html { redirect_to admins_event_station_path(@current_event, @station), notice: t("alerts.updated") }
      format.json { render json: @station }
    end
  end

  def update
    respond_to do |format|
      if @station.update(permitted_params)
        format.html { redirect_to admins_event_station_path(@current_event, @station), notice: t("alerts.updated") }
        format.json { render status: :ok, json: @station }
      else
        format.html { render :edit }
        format.json { render json: @station.errors.to_json, status: :unprocessable_entity }
      end
    end
  end

  def clone
    @station = @station.deep_clone(include: %i[station_catalog_items products topup_credits access_control_gates], validate: false)
    index = @station.name.index(' - ')
    if index.nil?
      name = @station.name
    else
      name = @station.name.byteslice(0...index)
    end
    @station.name = "#{name} - #{@current_event.stations.where("stations.name LIKE :l_name", {:l_name => "#{name}%"}).count}"
    @station.save!
    redirect_to [:admins, @current_event, @station], notice: t("alerts.created")
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
    params[:order].each_value { |value| @current_event.stations.find(value[:id]).update_attribute(:position, value[:position]) }
    render nothing: true
  end

  private

  def set_station
    id = params[:id] || params[:station_id]
    @station = @current_event.stations.find(id)
    authorize @station
    @group = @station.group
  end

  def permitted_params
    params.require(:station).permit(:name, :location, :category, :reporting_category, :address, :registration_num, :official_name, :hidden)
  end
end
