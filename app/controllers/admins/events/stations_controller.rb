class Admins::Events::StationsController < Admins::Events::BaseController
  before_action :set_station, except: %i[index new create]

  def index
    @group = params[:group]
    @stations = @current_event.stations.where(category: Station::GROUPS[@group.to_sym]).order(hidden: :asc, name: :asc)
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

  def update
    respond_to do |format|
      if @station.update(permitted_params)
        format.html { redirect_to admins_event_station_path(@current_event, @station), notice: t("alerts.updated") }
        format.json { render json: @station }
      else
        flash.now[:alert] = t("alerts.error")
        format.html { render :edit }
        format.json { render json: { errors: @station.errors }, status: :unprocessable_entity }
      end
    end
  end

  def clone
    @station = @station.deep_clone(include: %i[station_catalog_items station_products topup_credits access_control_gates], validate: false)
    @station.name = "#{@station.name} - #{rand(10_000)}"
    @station.save!
    redirect_to admins_event_station_path(@current_event, @station)
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

  private

  def set_station
    id = params[:id] || params[:station_id]
    @station = @current_event.stations.find(id)
    authorize @station
    @group = @station.group
  end

  def permitted_params
    params.require(:station).permit(:name,
                                    :location,
                                    :event_id,
                                    :category,
                                    :reporting_category,
                                    :address,
                                    :registration_num,
                                    :official_name,
                                    :hidden)
  end
end
