module Admins
  module Events
    class AnalyticsController < Admins::Events::BaseController
      include ApplicationHelper
      include AnalyticsHelper

      before_action :authorize_billing
      before_action :check_request_format, only: %w[cash_flow sales gates partner_reports]

      def show
        @top_products = @current_event.pokes.top_products.as_json

        non_alcohol = @current_event.pokes.where(action: "sale", product: Product.where(station: @current_event.stations, is_alcohol: false))
        alcohol = @current_event.pokes.where(action: "sale", product: Product.where(station: @current_event.stations, is_alcohol: true))
        @alcohol_products = [{ is_alcohol: "Non Alcohol", credits: -non_alcohol.sum(:credit_amount), amount: non_alcohol.count }, { is_alcohol: "Alcohol", credits: -alcohol.sum(:credit_amount), amount: alcohol.count }]
      end

      def cash_flow
        metrics = JSON.parse(PokesQuery.new(@current_event).cash_flow_by_day)
        @views = { chart_id: "cash_flow", title: "Cash Flow", cols: ["Amount"], currency: @current_event.currency_symbol, data: metrics, metric: ["Money"], decimals: 1 }
        @partial = 'admins/events/analytics/cash_flow'
        prepare_data(params[:action])
      end

      def partner_reports
        cols = ["Action", "Description", "Location", "Station Type", "Station Name", "Money", "Payment Method", "Event Day", "Date Time"]
        @money = prepare_pokes(cols, pokes_money)

        cols = ["Action", "Description", "Location", "Station Type", "Station Name", "Credit Name", "Credits", "Device", "Event Day", "Date Time"]
        @credits = prepare_pokes(cols, pokes_credits)

        cols = ['Description', 'Location', 'Station Type', 'Station Name', 'Product Name', 'Event Day', 'Date Time', 'Operator UID', 'Operator Name', 'Device', 'Credit Name', 'Credits']
        product_sale = pokes_sales(@current_event.credits.pluck(:id))
        sales = prepare_pokes(cols, product_sale)

        cols = ['Product Name', 'Credits', 'sorter']
        top_products = prepare_pokes(cols, @current_event.pokes.top_products.as_json)
        @views = [
          { chart_id: "money_recon", title: "Money Reconciliation Summary", cols: ["Payment Method"], rows: ["Action", "Station Name"], data: @money, metric: ["Money"], decimals: 1 },
          { chart_id: "money_flow", title: "Money Flow", cols: ["Event Day"], rows: ["Action"], data: @money, metric: ["Money"], decimals: 1 },
          { chart_id: "topups_statiom", title: "Topup-Refund by Hour / Station", cols: ["Date Time"], rows: ["Station Name"], data: @money, metric: ["Money"], decimals: 1, partial: "chart_card", type: "Stacked Bar Chart" },
          { chart_id: "topups_payment", title: "Topup-Refund Cash / Card / Virtual by Hour", cols: ["Date Time"], rows: ["Payment Method"], data: @money, metric: ["Money"], decimals: 1, partial: "chart_card", type: "Bar Chart" },
          { chart_id: "topups_popular", title: "Most Popular Top-Up Amounts", cols: [], rows: ["Amount"], data: PokesQuery.new(@current_event).top_topup, metric: ["Customers"], decimals: 0, partial: "chart_card", type: "Bar Chart" },
          { chart_id: "customer_topup", title: "Customer Topups", partial: "doughnut_card", cols: "Avg. Topup", data: PokesQuery.new(@current_event).customer_topup },
          { chart_id: "refund_popular", title: "Most Popular Refund Amounts", cols: [], rows: ["Amount"], data: PokesQuery.new(@current_event).top_refund, metric: ["Customers"], decimals: 0, partial: "chart_card", type: "Bar Chart" },
          { chart_id: "high_sales", title: "High-Level Sale", cols: ["Credit Name"], rows: ["Station Name"], data: sales, metric: ["Credits"], decimals: 1 },
          { chart_id: "high_sales_chart", title: "Total Sales by Hour", cols: ["Date Time"], rows: ["Station Type"], data: sales, metric: ["Credits"], decimals: 1, partial: "chart_card", type: "Stacked Bar Chart" },
          { chart_id: "top_sales_amount", title: "Top 10 Product Sales (Amount)", cols: ["sorter", "Product Name"], rows: [], data: top_products, metric: ["Credits"], decimals: 1, partial: "chart_card", type: "Horizontal Bar Chart" },
          { chart_id: "top_sales_quantity", title: "Top 10 Product Sales (Quantity)", cols: ["sorter", "Product Name"], rows: [], data: PokesQuery.new(@current_event).top_product_quantity, metric: ["Quantity"], decimals: 0, partial: "chart_card", type: "Horizontal Bar Chart" },
          { chart_id: "spending_customer", title: "Customer Spending Distribution", cols: [], rows: ["Spent amount"], data: PokesQuery.new(@current_event).spending_customer, metric: ["Customers"], decimals: 0, partial: "chart_card", type: "Bar Chart" },
          { chart_id: "topups_perfourmance", title: "Topup-Refund Perfourmance by Hour", cols: ["Date Time"], rows: ["Station Name"], data: @money, metric: ["Money"], decimals: 1, partial: "chart_card", type: "Stacked Bar Chart" },
          { chart_id: "sales_perfourmance", title: "Sales Performance by Hour", cols: ["Date Time"], rows: ["Station Name"], data: sales, metric: ["Credits"], decimals: 1, partial: "chart_card", type: "Stacked Bar Chart" }
        ]

        prepare_data(params[:action])
      end

      def sales
        sale_credit = -@current_event.pokes.where(credit: @current_event.credit).sales.is_ok.sum(:credit_amount)
        sale_virtual = -@current_event.pokes.where(credit: @current_event.virtual_credit).sales.is_ok.sum(:credit_amount)
        total_sale = -@current_event.pokes.where(credit: @current_event.credits).sales.is_ok.sum(:credit_amount)

        cols = ["Description", "Location", "Station Type", "Station Name", "Product Name", "Credit Name", "Credits", "Event Day", "Operator UID", "Operator Name", "Device"]
        product_sale = pokes_sales(@current_event.credits.pluck(:id))
        sales = prepare_pokes(cols, product_sale)

        stock_cols = ["Description", "Location", "Station Type", "Station Name", "Product Name", "Product Quantity", "Event Day", "Operator UID", "Operator Name", "Device"]
        products_stock = prepare_pokes(stock_cols, pokes_sale_quantity)

        @totals = { sale_credit: sale_credit, sale_virtual: sale_virtual, total_sale: total_sale }.map { |k, v| [k, number_to_token(v)] }
        @views = [
          { chart_id: "products_", title: "Products Sale", cols: ["Event Day", "Credit Name"], rows: ["Location", "Station Type", "Station Name"], data: sales, metric: ["Credits"], decimals: 1 },
          { chart_id: "products_stock", title: "Products Sale Stock", cols: ["Event Day"], rows: ["Location", "Station Type", "Station Name"], data: products_stock, metric: ["Product Quantity"], decimals: 0 }
        ]

        prepare_data(params[:action])
      end

      def gates
        total_checkins = @current_event.pokes.where(action: "checkin").count
        total_access = @current_event.pokes.sum(:access_direction)
        activations = @current_event.customers.count
        staff = @current_event.customers.where(operator: true).count

        rate_cols = ["Ticket Type", "Total Tickets", "Redeemed"]
        checkin_rate = prepare_pokes(rate_cols, @current_event.ticket_types.checkin_rate.as_json)
        cols = ["Action", "Description", "Location", "Station Type", "Station Name", "Catalog Item", "Ticket Type", "Total Tickets", "Event Day", "Date Time", "Operator UID", "Operator Name", "Device"]
        checkin_ticket_type = prepare_pokes(cols, pokes_checkin)
        cols = ["Station Name", "Event Day", "Date Time", "Direction", "Capacity", "Zone"]
        access_control = prepare_pokes(cols, pokes_access)

        @totals = { total_checkins: total_checkins, total_access: total_access, activations: activations, staff: staff }.map { |k, v| [k, number_to_delimited(v)] }
        @views = [{ chart_id: "checkin_rate", title: "Ticket Check-in Rate", cols: [], rows: ["Ticket Type", "Redeemed"], data: checkin_rate, metric: ["Total Tickets"], decimals: 0, partial: "chart_card", type: "Table" },
                  { chart_id: "checkin_ticket_type", title: "Check-in and Box office purchase", cols: ["Date Time"], rows: ["Catalog Item"], data: checkin_ticket_type, metric: ["Total Tickets"], decimals: 0, partial: "chart_card", type: "Stacked Bar Chart" },
                  { chart_id: "access_control", title: "Venue Capacity", cols: ["Date Time"], rows: ["Zone"], data: access_control, metric: ["Capacity"], decimals: 0, partial: "chart_card", type: "Stacked Bar Chart" }]
        prepare_data(params["action"])
      end

      private

      def authorize_billing
        authorize(@current_event, :analytics?)
        @load_analytics_resources = true
        @credit_value = @current_event.credit.value
        @credit_name = @current_event.credit.name
        @customers = @current_event.customers.count - @current_event.customers.where(operator: true).count
      end

      def check_request_format
        return if request.format.js?
        flash.now[:alert] = 'Unable to open in a new tab'

        respond_to do |format|
          format.html { render action: :show }
        end
      end

      def prepare_data(name)
        @name = name
        respond_to do |format|
          format.js { render action: :load_view }
        end
      end
    end
  end
end
