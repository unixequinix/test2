class Admins::Events::ReportsController < Admins::Events::BaseController
  # rubocop:disable all
  include ReportsHelper

  before_action :load_reports_resources, :set_variables

  def money_recon
    authorize(:poke, :reports_billing?)

    @total_money = @current_event.pokes.is_ok.sum(:monetary_total_price)
    @topup = @current_event.pokes.is_ok.topups.sum(:monetary_total_price)
    @refund = -@current_event.pokes.is_ok.refunds.sum(:monetary_total_price)
    @online_money_left = @current_event.pokes.is_ok.online.sum(:monetary_total_price) - @current_event.pokes.is_ok.online_orders.sum(:credit_amount)*@current_event.credit.value

    activations = Poke.connection.select_all(query_activations(@current_event.id)).map { |h| h["Activations"] }.compact.sum
    total_topup = @current_event.pokes.topups.is_ok.sum(:monetary_total_price)
    @avg_topups = total_topup / activations

    money_cols = ["Action", "Description", "Location", "Station Type", "Station Name", "Money", "Payment Method", "Event Day"]
    @money = prepare_pokes(money_cols,  @current_event.pokes.money_recon)
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

  def products_sale
    authorize(:poke, :reports?)

    @sale_credit = -@current_event.pokes.where(credit: @credit).sales.is_ok.sum(:credit_amount)
    @sale_virtual = -@current_event.pokes.where(credit: @virtual).sales.is_ok.sum(:credit_amount)

    activations = Poke.connection.select_all(query_activations(@current_event.id)).map { |h| h["Activations"] }.compact.sum
    total_sale = -@current_event.pokes.where(credit: @all_credits).sales.is_ok.sum(:credit_amount)
    @avg_products_sale = total_sale / activations

    cols = ["Description", "Location", "Station Type", "Station Name", "Product Name", "Credit Name", "Credits", "Event Day", "Operator UID", "Operator Name", "Device"]
    @products = prepare_pokes(cols, @current_event.pokes.products_sale)
    stock_cols = ["Description", "Location", "Station Type", "Station Name", "Product Name", "Quantity", "Event Day", "Operator UID", "Operator Name", "Device"]
    @products_stock = prepare_pokes(stock_cols, @current_event.pokes.products_sale_stock)
    @top_products = @current_event.pokes.top_products.where(credit: @all_credits).to_json

    query_top_quantity_sql = query_top_quantity(@current_event.id)
    @top_quantity =  Poke.connection.select_all(query_top_quantity_sql).to_json
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

    @token_symbol = @current_event.credit.symbol
    @currency_symbol = @current_event.currency_symbol
  end
end
