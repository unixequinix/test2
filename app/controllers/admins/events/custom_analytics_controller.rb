module Admins
  module Events
    class CustomAnalyticsController < Admins::Events::BaseController
      include EventsHelper
      include AnalyticsHelper

      before_action :authorize_billing
      before_action :skip_authorization, only: %i[money access credits checkin sales]

      def money
        cols = ['Action', 'Description', 'Source', 'Location', 'Station Type', 'Station Name', 'Payment Method', 'Event Day', 'Date Time', 'Operator UID', 'Operator Name', 'Device', 'Money']
        online_purchase = @current_event.orders.online_purchase.as_json
        onsite_money = @current_event.pokes.money_recon_operators(%w[none other]).as_json
        online_refunds = @current_event.refunds.online_refund.each { |o| o.money = o.money * @credit_value }.as_json
        products_sale = @current_event.pokes.products_sale(@current_event.credit.id).as_json.map { |o| o.merge('money' => -1 * o['credit_amount'] * @credit_value) }
        @money = prepare_pokes(cols, onsite_money + online_purchase + online_refunds + products_sale)
        prepare_data params[:action], @money, [['Payment Method'], ['Action'], ['Money'], 1]
      end

      def credits
        cols = ['Action', 'Description', 'Location', 'Station Type', 'Station Name', 'Device', 'Event Day', 'Date Time', 'Credit Name', 'Credits']
        online_packs = Order.online_packs(@current_event).as_json
        # TODO: differentiate creedits comming from orders and tickets (android side)
        # ticket_packs = Ticket.online_packs(@current_event).as_json
        online_topup = @current_event.orders.online_topup.as_json
        order_fee = @current_event.orders.online_purchase_fee
        order_fee.each do |o|
          o.credit_name = @credit_name
          o.credit_amount = o.credit_amount / @credit_value
        end
        credits_onsite = @current_event.pokes.credit_flow.as_json
        credits_refunds = @current_event.refunds.online_refund_credits.each { |o| o.credit_name = @credit_name }.as_json
        credits_refunds_fee = @current_event.refunds.online_refund_fee.each { |o| o.credit_name = @credit_name }.as_json
        @credits = prepare_pokes(cols, online_packs + online_topup + credits_onsite + credits_refunds + credits_refunds_fee + order_fee)
        prepare_data params[:action], @credits, [['Credit Name'], ['Action'], ['Credits'], 1]
      end

      def sales
        cols = ['Description', 'Location', 'Station Type', 'Station Name', 'Alcohol Product', 'Product Name', 'Event Day', 'Date Time', 'Operator UID', 'Operator Name', 'Device', 'Credit Name', 'Credits']
        @sales = prepare_pokes(cols, @current_event.pokes.products_sale(@current_event.credits.pluck(:id)).as_json)
        prepare_data params[:action], @sales, [['Event Day', 'Credit Name'], ['Location', 'Station Type', 'Station Name'], ['Credits'], 1]
      end

      def checkin
        cols = ['Action', 'Description', 'Location', 'Station Type', 'Station Name', 'Event Day', 'Date Time', 'Operator UID', 'Operator Name', 'Device', 'Catalog Item', 'Ticket Type', 'Total Tickets']
        @checkin = prepare_pokes(cols, @current_event.pokes.checkin_ticket_type.as_json)
        prepare_data params[:action], @checkin, [['Event Day'], ['Catalog Item'], ['Total Tickets'], 0]
      end

      def access
        # TODO: delete access when access reports refactor
        access_cols = ["Station Name", "Event Day", "Date Time", "Direction", "Capacity", "Access", "Zone"]
        @access = prepare_pokes(access_cols, @current_event.pokes.access.as_json)
        prepare_data params[:action], @access, [['Direction'], ['Zone', 'Date Time'], ['Capacity'], 0]
      end

      private

      def authorize_billing
        authorize(@current_event, :custom_analytics?)
        @load_analytics_resources = true
        @credit_value = @current_event.credit.value
        @credit_name = @current_event.credit.name
      end

      def prepare_data(name, data, array)
        @data = data
        @cols, @rows, @metric, @decimals = array
        @name = name

        respond_to do |format|
          format.js { render action: :load_report }
        end
      end
    end
  end
end
