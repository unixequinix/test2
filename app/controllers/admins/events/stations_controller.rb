class Admins::Events::StationsController < Admins::Events::BaseController # rubocop:disable Metrics/ClassLength
  include ReportsHelper

  before_action :set_station, :set_variables, except: %i[index new create]

  def reports
    @load_reports_resources = true
    authorize(:poke, :reports?)

    money_cols = ["Action", "Description", "Money", "Payment Method", "Event Day", "Operator UID", "Operator Name", "Device"]
    @money = prepare_pokes(money_cols, @station.pokes.money_recon_operators)
    credit_cols = ["Action", "Description", "Credit Name", "Credits", "Operator UID", "Operator Name", "Device", "Event Day"]
    @credits = prepare_pokes(credit_cols, @station.pokes.credit_flow)
    product_cols = ["Description", "Product Name", "Credit Name", "Credits", "Event Day", "Operator UID", "Operator Name", "Device"] # rubocop:disable Metrics/LineLength
    @products = prepare_pokes(product_cols, @station.pokes.products_sale)
    stock_cols = ["Description", "Product Name", "Quantity", "Event Day", "Operator UID", "Operator Name", "Device"]
    @products_stock = prepare_pokes(stock_cols, @station.pokes.products_sale_stock)
    access_cols = ["Event Day", "Date Time", "Direction", "Access"]
    @access_control = prepare_pokes(access_cols, @station.pokes.access)
    ticket_cols = ["Action", "Catalog Item", "Total Tickets", "Money", "Event Day", "Operator UID", "Operator Name", "Device"]
    @checkin_ticket_type = prepare_pokes(ticket_cols, @station.pokes.checkin_ticket_type)
  end

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
    @sales = - @station.pokes.where(credit: @all_credits).sales.is_ok.sum(:credit_amount)
    @sales_credits = - @station.pokes.where(credit: @credit).sales.is_ok.sum(:credit_amount)
    @operators = @station.pokes.pluck(:operator_id).uniq.count
    @devices = @station.pokes.pluck(:device_id).uniq.count
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
    name = if index.nil?
             @station.name
           else
             @station.name.byteslice(0...index)
           end
    @station.name = "#{name} - #{@current_event.stations.where('stations.name LIKE :l_name', l_name: "#{name}%").count}"
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

  def set_variables
    @credit = @current_event.credit
    @virtual = @current_event.virtual_credit
    @all_credits = [@credit, @virtual]
  end
end
