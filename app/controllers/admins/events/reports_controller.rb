class Admins::Events::ReportsController < Admins::Events::BaseController
  # rubocop:disable all
  include ReportsHelper

  before_action :load_reports_resources, :set_variables

  def show
    authorize(:poke, :reports_billing?)

    @total_money = @current_event.pokes.is_ok.sum(:monetary_total_price)
    @total_credits = @current_event.pokes.where(credit: @all_credits).is_ok.sum(:credit_amount)
    @total_products_sale = -@current_event.pokes.where(credit: @all_credits).sales.is_ok.sum(:credit_amount)
    @total_checkins = @current_event.tickets.where(redeemed: true).count
    @total_activations = Poke.connection.select_all(query_activations(@current_event.id)).map { |h| h["Activations"] }.compact.sum
    @total_devices = @current_event.pokes.is_ok.devices.map { |h| h["total_devices"] }.compact.sum

    @sales = @current_event.pokes.sales.is_ok.where(credit: @all_credits).group_by_hour(:date, format: "%Y-%m-%d %HH").sum("-1 * credit_amount")
    @record_credit = @current_event.pokes.record_credit.is_ok.where(credit: @all_credits).group_by_hour(:date, format: "%Y-%m-%d %HH").sum(:credit_amount)

  end

  def money_recon
    @load_reports_resources = false
    authorize(:poke, :reports_billing?)

    @total_money = @current_event.pokes.is_ok.sum(:monetary_total_price)
    @topup = @current_event.pokes.is_ok.topups.sum(:monetary_total_price)
    @refund = -@current_event.pokes.is_ok.refunds.sum(:monetary_total_price)
    @online_money_left = @current_event.pokes.is_ok.online.sum(:monetary_total_price) - @current_event.pokes.is_ok.online_orders.sum(:credit_amount)*@current_event.credit.value

    money_cols = ["Action", "Description", "Location", "Station Type", "Station Name", "Money", "Payment Method", "Event Day"]
    @money = prepare_pokes(money_cols,  @current_event.pokes.money_recon)
    op_cols = ["Action", "Description", "Location", "Station Type", "Station Name", "Money", "Payment Method", "Event Day", "Operator UID", "Operator Name", "Device"]
    @operators = prepare_pokes(op_cols, @current_event.pokes.money_recon_operators)
  end

  def products_sale
    authorize(:poke, :reports?)

    @sale_credit = -@current_event.pokes.where(credit: @credit).sales.is_ok.sum(:credit_amount)
    @sale_virtual = -@current_event.pokes.where(credit: @virtual).sales.is_ok.sum(:credit_amount)

    cols = ["Description", "Location", "Station Type", "Station Name", "Product Name", "Credit Name", "Credits", "Event Day", "Operator UID", "Operator Name", "Device"] # rubocop:disable Metrics/LineLength 
    @products = prepare_pokes(cols, @current_event.pokes.products_sale)
    stock_cols = ["Description", "Location", "Station Type", "Station Name", "Product Name", "Quantity", "Event Day", "Operator UID", "Operator Name", "Device"] 
    @products_stock = prepare_pokes(stock_cols, @current_event.pokes.products_sale_stock)
  end

  def cashless
    authorize(:poke, :reports?)

    @record_credit = @current_event.pokes.where(credit: @credit).record_credit.is_ok.sum(:credit_amount)
    @record_credit_virtual = @current_event.pokes.where(credit: @virtual).record_credit.is_ok.sum(:credit_amount)

    @fees = - @current_event.pokes.fees.is_ok.sum(:credit_amount)
    @orders = @current_event.pokes.online_orders.is_ok.sum(:credit_amount)
    cols = ["Action", "Description", "Location", "Station Type", "Station Name", "Credit Name", "Credits", "Device","Event Day"]
    @credits = prepare_pokes(cols, @current_event.pokes.credit_flow)
  end

  def gates
    authorize(:poke, :reports?)

    @total_checkins = @current_event.tickets.where(redeemed: true).count
    @total_access = @current_event.pokes.sum(:access_direction)

    ticket_cols = ["Action", "Description", "Location", "Station Type", "Station Name", "Catalog Item", "Ticket Type", "Total Tickets", "Event Day", "Operator UID", "Operator Name", "Device"]
    @checkin_ticket_type = prepare_pokes(ticket_cols, @current_event.pokes.checkin_ticket_type)
    rate_cols = ["Ticket Type", "Total Tickets", "Redeemed"]
    @checkin_rate = prepare_pokes(rate_cols, @current_event.ticket_types.checkin_rate)
    access_cols = ["Location", "Station Type", "Station Name", "Event Day", "Date Time", "Direction", "Access"]
    @access_control = prepare_pokes(access_cols, @current_event.pokes.access)
  end

  def activations
    authorize(:poke, :reports_billing?)
    activations_sql = query_activations(@current_event.id)
    @activations =  Poke.connection.select_all(activations_sql).to_json
  end

  def devices
    authorize(:poke, :reports_billing?)
    @devices = prepare_pokes(["Station Name", "Event Day", "Total Devices"], @current_event.pokes.devices)
  end

  private

  def load_reports_resources
    @load_reports_resources = true
  end

  def set_variables
    @credit = @current_event.credit
    @virtual = @current_event.virtual_credit 
    @all_credits = [@credit, @virtual]
  end
end


