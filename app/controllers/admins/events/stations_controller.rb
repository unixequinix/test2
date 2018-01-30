class Admins::Events::StationsController < Admins::Events::BaseController
  include ReportsHelper

  before_action :set_station, :set_variables, except: %i[index new create]
  before_action :set_groups, only: %i[index new create edit update]

  def reports
    @load_reports_resources = true
    authorize(:poke, :reports?)

    money_cols = ["Action", "Description", "Money", "Payment Method", "Event Day", "Operator UID", "Operator Name", "Device"]
    @money = prepare_pokes(money_cols, @station.pokes.money_recon_operators)
    credit_cols = ["Action", "Description", "Credit Name", "Credits", "Operator UID", "Operator Name", "Device", "Event Day"]
    @credits = prepare_pokes(credit_cols, @station.pokes.credit_flow)
    product_cols = ["Description", "Product Name", "Credit Name", "Credits", "Event Day", "Operator UID", "Operator Name", "Device"]
    @products = prepare_pokes(product_cols, @station.pokes.products_sale)
    stock_cols = ["Description", "Product Name", "Quantity", "Event Day", "Operator UID", "Operator Name", "Device"]
    @products_stock = prepare_pokes(stock_cols, @station.pokes.products_sale_stock)
    access_cols = ["Event Day", "Date Time", "Direction", "Access"]
    @access_control = prepare_pokes(access_cols, @station.pokes.access)
    ticket_cols = ["Action", "Catalog Item", "Total Tickets", "Money", "Event Day", "Operator UID", "Operator Name", "Device"]
    @checkin_ticket_type = prepare_pokes(ticket_cols, @station.pokes.checkin_ticket_type)
  end

  def index
    @q = @current_event.stations.includes(:access_control_gates, :topup_credits, :station_catalog_items, :products)
                       .order(:hidden, :category, :name)
                       .where.not(category: "touchpoint")
                       .ransack(params[:q])
    @stations = @q.result
    authorize @stations
    @station = @current_event.stations.new
    @stations = @stations.group_by(&:group)
  end

  def show
    authorize @station
    @items = @station.all_station_items
    @items.sort_by! { |i| i.class.sort_column.to_s } if @items.first
    @transactions = @station.transactions
    @sales = - @station.pokes.where(credit: @all_credits).sales.is_ok.sum(:credit_amount)
    @sales_credits = - @station.pokes.where(credit: @credit).sales.is_ok.sum(:credit_amount)
    @operators = @station.pokes.pluck(:operator_id).uniq.count
    @devices = @station.pokes.pluck(:device_id).uniq.count
    @available_ticket_types = @current_event.ticket_types.where.not(id: @station.ticket_types).includes(:company)
    @current_ticket_types = @current_event.ticket_types.where(id: @station.ticket_types).includes(:company)
  end

  def new
    @station = @current_event.stations.new
    authorize @station
  end

  def create
    @station = @current_event.stations.new(permitted_params)
    authorize @station

    if @station.save
      redirect_to admins_event_station_path(@current_event, @station), notice: t("alerts.created")
    else
      flash.now[:alert] = t("alerts.error")
      render :new
    end
  end

  def edit; end

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

  def add_ticket_types
    ticket_types = @current_event.ticket_types.find(permitted_params['ticket_type_ids']) + @station.ticket_types
    @station.update(ticket_types: ticket_types)
    redirect_to admins_event_station_path(@current_event, @station), notice: t("alerts.updated")
  end

  def remove_ticket_types
    ticket_types = @station.ticket_types.where.not(id: permitted_params['ticket_type_ids']).pluck(:id)
    @station.update(ticket_type_ids: ticket_types)
    redirect_to admins_event_station_path(@current_event, @station), notice: t("alerts.updated")
  end

  def clone
    @station = @station.deep_clone(include: %i[station_catalog_items products topup_credits access_control_gates], validate: false)
    index = @station.name.index(' - ')
    # TODO: Please, please. This is fucking embarrassing code
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

  def set_groups
    @group = params[:group]
    groups = Station::GROUPS
    groups = groups.slice(@group.to_sym) if @group
    @categories = groups.to_a.map { |key, arr| [key.to_s.humanize, arr.map { |s| [s.to_s.humanize, s] }] }
  end

  def set_station
    id = params[:id] || params[:station_id]
    @station = @current_event.stations.find(id)
    authorize @station
    @group = @station.group
  end

  def permitted_params
    params.require(:station).permit(:name, :location, :category, :reporting_category, :address, :registration_num, :official_name, :hidden, ticket_type_ids: [])
  end

  def set_variables
    @credit = @current_event.credit
    @virtual = @current_event.virtual_credit
    @all_credits = [@credit, @virtual]
  end
end
