module Admins
  module Events
    class CustomAnalyticsController < Admins::Events::BaseController
      include EventsHelper
      include AnalyticsHelper

      before_action :authorize_billing
      before_action :skip_authorization, only: %i[money access credits checkin sales]

      def show
        @message = analytics_message(@current_event)
      end

      def money
        cols = ['Action', 'Description', 'Source', 'Location', 'Station Type', 'Station Name', 'Payment Method', 'Event Day', 'Date Time', 'Operator UID', 'Operator Name', 'Device', 'Money']
        @money = prepare_pokes(cols,  @current_event.pokes.money_recon_operators)
        prepare_data params[:action], @money, [['Event Day'], ['Action'], ['Money'], 1]
      end

      def credits
        cols = ['Action', 'Description', 'Location', 'Station Type', 'Station Name', 'Device', 'Event Day', 'Date Time', 'Credit Name', 'Credits']
        @credits = prepare_pokes(cols, @current_event.pokes.credit_flow)
        prepare_data params[:action], @credits, [['Event Day'], ['Action'], ['Credits'], 1]
      end

      def sales
        cols = ['Description', 'Location', 'Station Type', 'Station Name', 'Product Name', 'Event Day', 'Date Time', 'Operator UID', 'Operator Name', 'Device', 'Credit Name', 'Credits']
        @sales = prepare_pokes(cols, @current_event.pokes.products_sale)
        prepare_data params[:action], @sales, [['Event Day', 'Credit Name'], ['Location', 'Station Type', 'Station Name'], ['Credits'], 1]
      end

      def checkin
        cols = ['Action', 'Description', 'Location', 'Station Type', 'Station Name', 'Event Day', 'Date Time', 'Operator UID', 'Operator Name', 'Device', 'Catalog Item', 'Ticket Type', 'Total Tickets']
        @checkin = prepare_pokes(cols, @current_event.pokes.checkin_ticket_type)
        prepare_data params[:action], @checkin, [['Event Day'], ['Catalog Item'], ['Total Tickets'], 0]
      end

      def access
        cols = ['Location', 'Station Type', 'Station Name', 'Event Day', 'Date Time', 'Direction', 'Access']
        @access = prepare_pokes(cols, @current_event.pokes.access)
        prepare_data params[:action], @access, [['Station Name', 'Direction'], ['Event Day', 'Date Time'], ['Access'], 0]
      end

      def activations
        @activations = PokesQuery.new(@current_event).activations
      end

      def devices
        @devices = prepare_pokes(["Station Name", "Event Day", "Total Devices"], @current_event.pokes.devices)
      end

      private

      def authorize_billing
        authorize(:poke, :custom_analytics?)
        @load_analytics_resources = true
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
