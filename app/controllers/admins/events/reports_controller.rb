class Admins::Events::ReportsController < Admins::Events::BaseController
  # rubocop:disable all
  include ReportsHelper

  before_action :load_reports_resources

  def money_recon
    authorize(:poke, :reports_billing?)

    @total_money = @current_event.pokes.is_ok.sum(:monetary_total_price)
    @topup = @current_event.pokes.is_ok.topups.sum(:monetary_total_price)
    @refund = -@current_event.pokes.is_ok.refunds.sum(:monetary_total_price)
    @online_money_left = @current_event.pokes.is_ok.online.sum(:monetary_total_price) - @current_event.pokes.is_ok.online_orders.sum(:credit_amount)*@current_event.credit.value

    activations = PokesQuery.new(@current_event).activations
    total_topup = @current_event.pokes.topups.is_ok.sum(:monetary_total_price)
    @avg_topups = total_topup / activations

    money_cols = ["Action", "Description", "Location", "Station Type", "Station Name", "Money", "Payment Method", "Event Day"]
    @money = prepare_pokes(money_cols,  @current_event.pokes.money_recon)
  end

  def cashless
    authorize(:poke, :reports?)

    @record_credit = @current_event.pokes.where(credit: @current_event.credit).record_credit.is_ok.sum(:credit_amount)
    @record_credit_virtual = @current_event.pokes.where(credit: @current_event.virtual_credit).record_credit.is_ok.sum(:credit_amount)

    @fees = - @current_event.pokes.fees.is_ok.sum(:credit_amount)
    @orders = @current_event.pokes.online_orders.is_ok.sum(:credit_amount)
    cols = ["Action", "Description", "Location", "Station Type", "Station Name", "Credit Name", "Credits", "Device","Event Day"]
    @credits = prepare_pokes(cols, @current_event.pokes.credit_flow)
  end

  def products_sale
    authorize(:poke, :reports?)

    @sale_credit = -@current_event.pokes.where(credit: @current_event.credit).sales.is_ok.sum(:credit_amount)
    @sale_virtual = -@current_event.pokes.where(credit: @current_event.virtual_credit).sales.is_ok.sum(:credit_amount)

    activations = PokesQuery.new(@current_event).activations
    total_sale = -@current_event.pokes.where(credit: @current_event.credits).sales.is_ok.sum(:credit_amount)
    @avg_products_sale = total_sale / activations

    cols = ["Description", "Location", "Station Type", "Station Name", "Product Name", "Credit Name", "Credits", "Event Day", "Operator UID", "Operator Name", "Device"]
    @products = prepare_pokes(cols, @current_event.pokes.products_sale)
    stock_cols = ["Description", "Location", "Station Type", "Station Name", "Product Name", "Quantity", "Event Day", "Operator UID", "Operator Name", "Device"]
    @products_stock = prepare_pokes(stock_cols, @current_event.pokes.products_sale_stock)
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
    @activations =  PokesQuery.new(@current_event).activations
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
