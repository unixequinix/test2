module Admins
  module Events
    class CustomAnalyticsController < Admins::Events::BaseController
      include EventsHelper
      include AnalyticsHelper

      before_action :authorize_billing
      before_action :skip_authorization, only: %i[money access credits checkin sales]

      def money
        cols = ['Action', 'Description', 'Source', 'Location', 'Station Type', 'Station Name', 'Payment Method', 'Event Day', 'Date Time', 'Customer ID', 'Customer UID', 'Customer Name', 'Operator UID', 'Operator Name', 'Device', 'Money']
        onsite_money = pokes_onsite_money(@current_event)
        online_purchase = @current_event.orders.online_purchase.as_json
        online_purchase_fee = @current_event.orders.online_purchase_fee.as_json
        online_refunds = @current_event.refunds.online_refund.each { |o| o.money = o.money * @credit_value }.as_json
        products_sale = pokes_sales(@current_event, @current_event.credit.id, @credit_value)
        @money = prepare_pokes(cols, onsite_money + online_purchase + online_purchase_fee + online_refunds + products_sale)
        prepare_data params[:action], @money, [['Payment Method'], ['Action'], ['Money'], 1]
      end

      def credits
        cols = ['Action', 'Description', 'Location', 'Station Type', 'Station Name', 'Device', 'Event Day', 'Date Time', 'Customer ID', 'Customer UID', 'Customer Name', 'Operator UID', 'Operator Name', 'Credit Name', 'Credits']
        online_packs = Order.online_packs(@current_event).as_json
        # TODO: differentiate creedits comming from orders and tickets (android side)
        # ticket_packs = Ticket.online_packs(@current_event).as_json
        online_topup = @current_event.orders.online_topup.as_json
        credits_onsite = pokes_onsite_credits(@current_event)
        credits_refunds = @current_event.refunds.online_refund_credits.each { |o| o.credit_name = @credit_name }.as_json
        credits_refunds_fee = @current_event.refunds.online_refund_fee.each { |o| o.credit_name = @credit_name }.as_json
        @credits = prepare_pokes(cols, online_packs + online_topup + credits_onsite + credits_refunds + credits_refunds_fee)
        prepare_data params[:action], @credits, [['Credit Name'], ['Action'], ['Credits'], 1]
      end

      def sales
        cols = ['Description', 'Location', 'Station Type', 'Station Name', 'Alcohol Product', 'Product Name', 'Event Day', 'Date Time', 'Customer ID', 'Customer UID', 'Customer Name', 'Operator UID', 'Operator Name', 'Device', 'Credit Name', 'Credits']
        product_sale = pokes_sales(@current_event, [@current_event.credit.id, @current_event.virtual_credit.id])
        @sales = prepare_pokes(cols, product_sale)
        prepare_data params[:action], @sales, [['Event Day', 'Credit Name'], ['Station Type', 'Station Name'], ['Credits'], 1]
      end

      def checkin
        cols = ['Action', 'Description', 'Location', 'Station Type', 'Station Name', 'Event Day', 'Date Time', 'Customer ID', 'Customer UID', 'Customer Name', 'Operator UID', 'Operator Name', 'Device', 'Catalog Item', 'Ticket Type', 'Ticket Code', 'Redeemed', 'Total Tickets']
        checkin = pokes_checkin(@current_event)
        @checkin = prepare_pokes(cols, checkin)
        prepare_data params[:action], @checkin, [['Event Day'], ['Catalog Item'], ['Total Tickets'], 0]
      end

      def access
        access_cols = ["Station Name", "Event Day", "Date Time", "Direction", "Capacity", "Access", "Zone"]
        access = pokes_access(@current_event)
        @access = prepare_pokes(access_cols, access)
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
