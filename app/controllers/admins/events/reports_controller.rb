class Admins::Events::ReportsController < Admins::Events::BaseController
  # rubocop:disable all
  include ReportsHelper

  before_action :load_reports_resources

  def gate_close_money_recon
    authorize(:stat, :gate_close_money_recon?)
    @total_money = @current_event.stats.sum(:monetary_total_price)

    # Money Income -----------------------------------------------------------------------------------
    @action_station_money_data, @action_station_money_column = view_builder('action_station_money', %w[station_name action], 'event_day')

    # Money Reconciliation by Operator ---------------------------------------------------------------
    operator_recon_columns = %w[station_name event_day operator_uid operator_name device_name action catalog_item_name]
    @operator_recon_data, @operator_recon_column = view_builder('operator_recon', operator_recon_columns, 'payment_method')
  end

  def gate_close_billing
    authorize(:stat, :gate_close_billing?)
    # Activations by Station and Event Day ---------------------------------------------------------------
    @activations_data, @activations_column, @total_activations = view_builder('activations', ['station_name'], 'event_day', 'activations')

    # Device Used ----------------------------------------------------------------------------------------
    @devices_data, @devices_column, @total_devices = view_builder('devices', ['station_name'], 'event_day', 'devices_count')
  end

  def cashless
    authorize(:stat, :cashless?)

    # Leftover Balance (Refundable and Non-Refundable) -----------------------------------------------------------------
    @leftover_balance_data, @leftover_balance_column = view_builder('leftover_balance', ['event_day'], 'credit_name')

    # Credit Flow ------------------------------------------------------------------------------------------------------
    @credit_flow_data, @credit_flow_column = view_builder('credit_flow', %w[transaction_type credit_name], 'event_day')

    # Topup & Refund by Station ----------------------------------------------------------------------------------------
    @topup_refund_data, @topup_refund_column = view_builder('topup_refund', %w[transaction_type station_type station_name credit_name], 'event_day')

    # Sales by Station / Device ----------------------------------------------------------------------------------------
    @sales_by_station_device_data, @sales_by_station_device_column = view_builder('sales_by_station_device', %w[station_type station_name device_name credit_name], 'event_day')
  end

  def products_sale
    authorize(:stat, :products_sale?)
    # Sales by station category ----------------------------
    @sales_by_station_data, @sales_by_station_column = view_builder('sales_by_station', %w[location station_type station_name credit_name], 'event_day')

    # Top Products by quantity -----------------------------
    data = data_connection(query_top_products_by_quantity(@current_event.id))
    @top_products_by_quantity_data = data.map { |hash| [hash["product_name"], hash["quantity"].to_i] }

    # Top Products by amount -----------------------------
    data = data_connection(query_top_products_by_amount(@current_event.id))
    @top_products_by_amount_data = data.map { |hash| [hash["product_name"], hash["amount"].to_f] }

    # Performance by Station -------------------------------------------------------------------------------------
    @perfomance_by_station_data = @current_event.stats.group(:station_name).group("to_char(date_trunc('hour', date ), 'HH24h DD-Mon-YY')").order("to_char(date_trunc('hour', date ), 'HH24h DD-Mon-YY')").where(credit_value: 1, action: 'sale').sum('-1 * credit_amount')

    # Products sale by station -----------------------------
    data = data_connection(query_products_sale_station(@current_event.id))
    @products_sale_station_data = pivot_products_sale_station(data).to_json

    columns = %w[station_type station_name product_name] + data.map { |hash| [hash["event_day"] + ".q", hash["event_day"] + ".a"] }.uniq.sort.flatten + ["total_quantity"] + ["total_amount"]
    @products_sale_station_column = (columns.map { |i| { "data" => i, "title" => i.humanize } }).to_json

    # Products sale overall-----------------------------
    data = data_connection(query_products_sale_overall(@current_event.id))
    @products_sale_overall_data = pivot_products_sale_overall(data).to_json

    columns = %w[product_name] + data.map { |hash| [hash["event_day"] + ".q", hash["event_day"] + ".a"] }.uniq.sort.flatten + ["total_quantity"] + ["total_amount"]
    @products_sale_overall_column = (columns.map { |i| { "data" => i, "title" => i.humanize } }).to_json
  end

  def operators
    authorize(:stat, :operators?)

    data = data_connection(query_operators_sale(@current_event.id))
    @operators_sale_data = pivot_operators_sale(data).to_json

    columns = %w[station_type station_name operator_uid operator_name device_name event_day product_name] + data.map { |hash| hash["credit_name"] }.uniq.sort + ["total_quantity"]
    @operators_sale_columns = (columns.map { |i| { "data" => i, "title" => i.humanize } }).to_json

    data = data_connection(query_operators_money(@current_event.id))
    @operators_money_data = pivot_operators_money(data).to_json

    columns = %w[station_type station_name operator_uid operator_name device_name event_day action catalog_item_name] + data.map { |hash| hash["payment_method"] }.uniq + ["total_money"]
    @operators_money_columns = (columns.map { |i| { "data" => i, "title" => i.humanize } }).to_json
  end

  def gates
    authorize(:stat, :gates?)
    # Tickets Checked In -----------------------------------------------------------------------------------------------
    @tickets_checkedin_data, @tickets_checkedin_column = view_builder('tickets_checkedin', %w[transaction_type ticket_type_name], 'event_day')

    # Checkin Rate % ---------------------------------------------------------------------------------------------------
    complete_ticket_list = Event.find(@current_event.id).tickets.group(:ticket_type_id).count.map { |id, count| [TicketType.find(id).name, count] }.to_h
    checked_ticket_list = Event.find(@current_event.id).stats.where(action: %w[checkin ticket_validation]).group(:ticket_type_name).count

    data = get_rate_data(complete_ticket_list, checked_ticket_list)
    @data_checkin_rate = data.map { |hash| [hash["ticket_type"], hash["rate"].to_i] }

    # Tickets Checked-in - by Station ----------------------------------------------------------------------------------
    @checkedin_by_station_data, @checkedin_by_station_column = view_builder('checkedin_by_station', %w[transaction_type station_name ticket_type_name], 'event_day')

    # Accreditation ----------------------------------------------------------------------------------------------------
    acc_sql = method("query_accreditation").call(@current_event.id)
    data = JSON.parse(Stat.connection.select_all(acc_sql).to_json)
    @accreditation_data = pivot_accreditation(data).to_json

    columns = %w[station_type station_name catalog_item_name] + data.map { |hash| [hash["event_day"] + ".q", hash["event_day"] + ".a"] }.uniq.sort.flatten + ["total_quantity"] + ["total_amount"]
    @accreditation_column = (columns.map { |i| { "data" => i, "title" => i.humanize } }).to_json

    # Gates -> Access Control by Station -------------------------------------------------------------------------------
    data = JSON.parse(Stat.connection.select_all(query_access_ctrl_station(@current_event.id)).to_json)
    @access_ctrl_data = pivot_access_ctrl_station(data).to_json

    columns = %w[station_type station_name] + data.map { |hash| [hash["event_day"] + ".in", hash["event_day"] + ".out"] }.uniq.sort.flatten + ["Access_Counter_In"] + ["Access_Counter_Out"]
    @access_ctrl_column = (columns.map { |i| { "data" => i, "title" => i.humanize } }).to_json

    # Gates -> Access Control - 30min ----------------------------------------------------------------------------------
    data = JSON.parse(Stat.connection.select_all(query_access_ctrl_min(@current_event.id)).to_json)
    @data = data
    @access_ctrl_min_data = pivot_access_ctrl_min(data).to_json

    columns = %w[event_day time_fraction] + data.map { |hash| [hash["station_name"] + ".in", hash["station_name"] + ".out"] }.uniq.sort.flatten + ["Access_Counter_In"] + ["Access_Counter_Out"]
    @access_ctrl_min_column = (columns.map { |i| { "data" => i, "title" => i.humanize } }).to_json
  end

  private

  def load_reports_resources
    @load_reports_resources = true
  end
end
