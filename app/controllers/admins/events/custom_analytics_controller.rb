module Admins
  module Events
    class CustomAnalyticsController < Admins::Events::BaseController
      include EventsHelper
      include AnalyticsHelper

      before_action :authorize_billing
      before_action :skip_authorization, only: %i[money access credits checkin sales]

      def download_raw_data
        respond_to do |format|
          format.csv { send_data(send("raw_data_#{params['act']}")) }
        end
      end

      def money
        cols = ['Action', 'Description', 'Source', 'Location', 'Station Type', 'Station Name', 'Payment Method', 'Event Day', 'Date Time', 'Customer UID', 'Customer Name', 'Operator UID', 'Operator Name', 'Device', 'Money']
        @money = prepare_pokes(cols, pokes_money)
        prepare_data params[:action], @money, [['Payment Method'], ['Action'], ['Money'], 1]
      end

      def credits
        cols = ['Action', 'Description', 'Location', 'Station Type', 'Station Name', 'Device', 'Event Day', 'Date Time', 'Customer UID', 'Customer Name', 'Operator UID', 'Operator Name', 'Credit Name', 'Credits']
        @credits = prepare_pokes(cols, pokes_credits)
        prepare_data params[:action], @credits, [['Credit Name'], ['Action'], ['Credits'], 1]
      end

      def sales
        cols = ['Description', 'Location', 'Station Type', 'Station Name', 'Alcohol Product', 'Product Name', 'Event Day', 'Date Time', 'Operator UID', 'Operator Name', 'Device', 'Credit Name', 'Credits']
        product_sale = pokes_sales(@current_event.credits.pluck(:id))
        @sales = prepare_pokes(cols, product_sale)
        prepare_data params[:action], @sales, [['Event Day', 'Credit Name'], ['Station Type', 'Station Name'], ['Credits'], 1]
      end

      def checkin
        cols = ['Action', 'Description', 'Location', 'Station Type', 'Station Name', 'Event Day', 'Date Time',  'Customer UID', 'Customer Name', 'Operator UID', 'Operator Name', 'Device', 'Catalog Item', 'Ticket Type', 'Ticket Code', 'Total Tickets']
        @checkin = prepare_pokes(cols, pokes_checkin)
        prepare_data params[:action], @checkin, [['Event Day'], ['Catalog Item'], ['Total Tickets'], 0]
      end

      def access
        access_cols = ["Station Name", "Event Day", "Date Time", "Direction", "Capacity", "Access", "Zone"]
        @access = prepare_pokes(access_cols, pokes_access)
        prepare_data params[:action], @access, [['Direction'], ['Zone', 'Date Time'], ['Capacity'], 0]
      end

      private

      def authorize_billing
        authorize(@current_event, :custom_analytics?)
        @load_analytics_resources = true
        @credit_value = @current_event.credit.value
        @credit_name = @current_event.credit.name
        @action = params['action']
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
