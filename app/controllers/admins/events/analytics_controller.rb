class Admins::Events::AnalyticsController < Admins::Events::BaseController
  # rubocop:disable all
  include ReportsHelper

  before_action :load_reports_resources, :set_variables
  before_action :skip_authorization, only: %i[money access credits checkin sales]

  def show
    authorize(:poke, :reports_billing?)
  end

  def money
    cols = ['Action', 'Description', 'Location', 'Station Type', 'Station Name', 'Payment Method', 'Event Day','Operator UID', 'Operator Name','Device', 'Money']
    @money = prepare_pokes(cols,  @current_event.pokes.money_recon_operators)
    prepare_data params[:action], @money, [['Event Day'], ['Action'], ['Money'], 1]
  end

  def credits
    cols = ['Action', 'Description', 'Location', 'Station Type', 'Station Name', 'Device','Event Day', 'Credit Name', 'Credits']
    @credits = prepare_pokes(cols, @current_event.pokes.credit_flow)
    prepare_data params[:action], @credits, [['Event Day'], ['Action'], ['Credits'], 1]
  end

  def sales
    cols = ['Description', 'Location', 'Station Type', 'Station Name', 'Product Name', 'Event Day', 'Operator UID', 'Operator Name', 'Device', 'Credit Name', 'Credits']
    @sales = prepare_pokes(cols, @current_event.pokes.products_sale)
    prepare_data params[:action], @sales, [['Event Day', 'Credit Name'], ['Location', 'Station Type','Station Name'], ['Credits'], 1]
  end

  def checkin
    cols = ['Action', 'Description', 'Location', 'Station Type', 'Station Name', 'Event Day', 'Operator UID', 'Operator Name', 'Device','Catalog Item', 'Ticket Type', 'Total Tickets']
    @checkin = prepare_pokes(cols, @current_event.pokes.checkin_ticket_type)
    prepare_data params[:action], @checkin, [['Event Day'], ['Catalog Item'], ['Total Tickets'], 0]
  end

  def access
    cols = ['Location', 'Station Type', 'Station Name', 'Event Day', 'Date Time', 'Direction', 'Access']
    @access = prepare_pokes(cols, @current_event.pokes.access)
    prepare_data params[:action], @access, [ ['Station Name','Direction'], ['Event Day', 'Date Time'], ['Access'], 0]
  end

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

  private

  def prepare_data name, data, array
    @data = data
    @cols, @rows, @metric, @decimals = array
    @name = name

    respond_to do |format|
      format.js { render action: :load_report }
    end
  end
end
