class Admins::Events::ReportsController < Admins::Events::BaseController
  # rubocop:disable all
  include ReportsHelper

  before_action :load_reports_resources

  def show
    authorize(:poke, :reports_billing?)
    credit = @current_event.credit

    @total_money = @current_event.pokes.is_ok.sum(:monetary_total_price)
    @total_credits = @current_event.pokes.where(credit: credit).is_ok.sum(:credit_amount)
    @total_products_sale = -@current_event.pokes.where(credit: credit).where(action: 'sale').is_ok.sum(:credit_amount)
    @total_checkins = @current_event.tickets.where(redeemed: true).count
    @total_activations = Poke.connection.select_all(query_activations(@current_event.id)).map { |h| h["Activations"] }.compact.sum
    @total_devices = @current_event.pokes.is_ok.devices.map { |h| h["total_devices"] }.compact.sum
  end

  def money_recon
    @load_reports_resources = false
    authorize(:poke, :reports_billing?)
    money_cols = ["Action", "Description", "Location", "Station Name", "Money", "Payment Method", "Event Day"]
    op_cols = ["Action", "Description", "Location", "Station Name", "Money", "Payment Method", "Event Day", "Operator UID", "Operator Name", "Device"]

    @money = prepare_pokes(money_cols,  @current_event.pokes.money_recon)
    @operators = prepare_pokes(op_cols, @current_event.pokes.money_recon_operators)
  end

  def products_sale
    authorize(:poke, :reports?)
    cols = ["Description", "Location", "Station Type", "Station Name", "Product Name", "Credit Name", "Credits", "Event Day", "Operator UID", "Operator Name", "Device"] # rubocop:disable Metrics/LineLength 
    @products = prepare_pokes(cols, @current_event.pokes.products_sale)
    stock_cols = ["Description", "Location", "Station Type", "Station Name", "Product Name", "Quantity", "Event Day", "Operator UID", "Operator Name", "Device"] 
    @products_stock = prepare_pokes(stock_cols, @current_event.pokes.products_sale_stock)
  end

  def cashless
    authorize(:poke, :reports?)
    cols = ["Action", "Description", "Location", "Station Type", "Station Name", "Credit Name", "Credits", "Device","Event Day"]
    @credits = prepare_pokes(cols, @current_event.pokes.credit_flow)
  end

  def gates
    authorize(:poke, :reports?)
    ticket_cols = ["Action", "Station Type", "Station Name", "Ticket Type", "Total Tickets", "Event Day", "Operator UID", "Operator Name", "Device"]
    rate_cols = ["Ticket Type", "Total Tickets", "Redeemed"]
    access_cols = ["Station Type", "Station Name", "Event Day", "Date Time", "Direction", "Access"]

    @checkin_ticket_type = prepare_pokes(ticket_cols, @current_event.pokes.checkin_ticket_type)
    @checkin_rate = prepare_pokes(rate_cols, @current_event.ticket_types.checkin_rate)
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
end


