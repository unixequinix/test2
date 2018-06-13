module Admins
  module Events
    class AnalyticsController < Admins::Events::BaseController
      include ApplicationHelper
      include AnalyticsHelper

      ANALYTICS_METHODS = %w[money_topups money_orders money_box_office money_online_refunds money_onsite_refunds money_fees credit_topups credit_sales credit_orders credit_credentials credit_box_office credit_onsite_refunds credit_online_refunds credit_outcome_fees credit_income_fees credit_outcome_orders].map { |s| [s.to_sym, s.to_sym] }.to_h.freeze

      before_action :authorize_billing
      before_action :check_request_format, only: %i[cash_flow gates partner_reports]

      def show
        @top_products = @current_event.pokes.top_products(10).as_json

        non_alcohol = @current_event.pokes.where(action: "sale", product: Product.where(station: @current_event.stations, is_alcohol: false))
        alcohol = @current_event.pokes.where(action: "sale", product: Product.where(station: @current_event.stations, is_alcohol: true))
        @alcohol_products = [{ is_alcohol: "Non Alcohol", credits: -non_alcohol.sum(:credit_amount), amount: non_alcohol.count }, { is_alcohol: "Alcohol", credits: -alcohol.sum(:credit_amount), amount: alcohol.count }]
      end

      def cash_flow
        cookies.delete :analytics_credit_report
        @money_income = @current_event.money_income
        @money_refunds = @current_event.money_refunds

        metrics = @current_event.plot(income: @money_income, refunds: @money_refunds)

        @views = { chart_id: "cash_flow", title: "Cash Flow", cols: ["Amount"], currency: @current_event.currency_symbol, data: metrics, metric: ["Money"], decimals: 1 }
        @partial = 'admins/events/analytics/cash_flow'
        prepare_view(params[:action])
      end

      def credits_flow
        @selected_report = cookies.signed[:analytics_credit_report]
        @credits = params[:credit_filter].present? ? @current_event.catalog_items.credits.where(id: params[:credit_filter]) : @current_event.credits
        cookies.signed[:analytics_credit_filter] = @credits.map(&:id)

        @credit_income = @current_event.credit_income(credit_filter: @credits)
        @credit_sales = @current_event.credit_sales(credit_filter: @credits)
        @credit_refunds = @current_event.credit_refunds(credit_filter: @credits)

        metrics = @current_event.plot(income: @credit_income, sales: @credit_sales, refunds: @credit_refunds)

        @views = { chart_id: "cash_flow", title: "Cash Flow", cols: ["Amount"], currency: @current_event.currency_symbol, data: metrics, metric: ["Credits"], decimals: 1 }
        @partial = 'admins/events/analytics/credits_flow'
        prepare_view(params[:action])
      end

      def partner_reports
        cols = ["Action", "Description", "Location", "Station Type", "Station Name", "Money", "Payment Method", "Event Day", "Date Time"]
        @money = prepare_pokes(cols, pokes_money)

        cols = ["Action", "Description", "Location", "Station Type", "Station Name", "Credit Name", "Credits", "Device", "Event Day", "Date Time"]
        @credits = prepare_pokes(cols, pokes_credits)

        cols = ['Description', 'Location', 'Station Type', 'Station Name', 'Product Name', 'Event Day', 'Date Time', 'Operator UID', 'Operator Name', 'Device', 'Credit Name', 'Credits']
        product_sale = pokes_sales
        sales = prepare_pokes(cols, product_sale)

        cols = ['Product Name', 'Credits', 'sorter']
        top_products = prepare_pokes(cols, @current_event.pokes.top_products(10).as_json)
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

        prepare_view(params[:action])
      end

      def gates
        total_checkins = @current_event.pokes.where(action: "checkin").count
        activations = @current_event.customers.count
        staff = @current_event.customers.where(operator: true).count

        rate_cols = ["Ticket Type", "Total Tickets", "Redeemed"]
        checkin_rate = prepare_pokes(rate_cols, @current_event.ticket_types.checkin_rate.as_json)
        cols = ["Action", "Description", "Location", "Station Type", "Station Name", "Catalog Item", "Ticket Type", "Total Tickets", "Event Day", "Date Time", "Operator UID", "Operator Name", "Device"]
        checkin_ticket_type = prepare_pokes(cols, pokes_checkin)
        cols = ["Station Name", "Event Day", "Date Time", "Direction", "Capacity", "Zone"]
        access_control = prepare_pokes(cols, pokes_access)

        @totals = { total_checkins: total_checkins, activations: activations, staff: staff }.map { |k, v| [k, number_to_delimited(v)] }
        @views = [{ chart_id: "checkin_rate", title: "Ticket Check-in Rate", cols: [], rows: ["Ticket Type", "Redeemed"], data: checkin_rate, metric: ["Total Tickets"], decimals: 0, partial: "chart_card", type: "Table" },
                  { chart_id: "checkin_ticket_type", title: "Check-in and Box office purchase", cols: ["Date Time"], rows: ["Catalog Item"], data: checkin_ticket_type, metric: ["Total Tickets"], decimals: 0, partial: "chart_card", type: "Stacked Bar Chart" },
                  { chart_id: "access_control", title: "Venue Capacity", cols: ["Date Time"], rows: ["Zone"], data: access_control, metric: ["Capacity"], decimals: 0, partial: "chart_card", type: "Stacked Bar Chart" }]
        prepare_view(params[:action])
      end

      def sub_report
        cookies.signed[:analytics_credit_report] = analytics_params[:selected]

        @credit = @current_event.credit
        @virtual_credit = @current_event.virtual_credit
        @credits = @current_event.credits.where(id: cookies.signed[:analytics_credit_filter])
        @event_currency = @current_event.currency_symbol

        send(ANALYTICS_METHODS[analytics_params[:data].to_sym])

        respond_to do |format|
          format.js { render action: :render_data, global: false }
        end
      end

      private

      def credit_topups
        @partial = "credit/topups"
        @stations = @current_event.stations.where(category: Event::TOPUPS_STATIONS).order(:category, :name)
        @topups = @current_event.credit_topups(credit_filter: @credits).reject { |_, v| v.zero? }

        crds = @current_event.credit_topups(grouping: :hour, credit_filter: @credit, station_filter: @stations)
        v_crds = @current_event.credit_topups(grouping: :hour, credit_filter: @virtual_credit, station_filter: @stations)
        data = @current_event.plot(credit: crds, virtual_credit: v_crds)
        @pos_views = { chart_id: "topups_flow", cols: ["Credits"], currency: "", data: data, decimals: 2 }
      end

      def credit_sales
        @filter = analytics_params[:filter][:station_type]
        @partial = "credit/sales"

        @stations = @current_event.stations.where(category: @filter)
        @dates = @current_event.credit_sales(credit_filter: @credits, station_filter: @stations).reject { |_, v| v.zero? }.keys.sort

        crds = @current_event.credit_sales(grouping: :hour, credit_filter: @credit, station_filter: @stations)
        v_crds = @current_event.credit_sales(grouping: :hour, credit_filter: @virtual_credit, station_filter: @stations)
        @pos_views = { chart_id: "sales_flow", cols: ["Credits"], currency: "", data: @current_event.plot(credit: crds, virtual_credit: v_crds), decimals: 2 }
        @top_stations = @current_event.pokes.top_stations(@filter, @credits).as_json
      end

      def credit_orders
        @partial = "credit/orders"

        @gateways = @current_event.credit_income_online_orders.select(:gateway).distinct.pluck(:gateway)
        @dates = @current_event.credit_online_orders_income(credit_filter: @credits).reject { |_, v| v.zero? }.keys.sort

        data = @gateways.map { |gateway| [gateway.underscore.to_sym, @current_event.credit_online_orders_income(grouping: :hour, credit_filter: @credits, payment_filter: gateway)] }.to_h
        @pos_views = { chart_id: "orders_flow", cols: ["Credits"], currency: "", data: @current_event.plot(data), decimals: 2 }
      end

      def credit_credentials
        @partial = "credit/credentials"

        crds = @current_event.credit_credential(grouping: :hour, credit_filter: @credit)
        v_crds = @current_event.credit_credential(grouping: :hour, credit_filter: @virtual_credit)
        @catalog_items = @current_event.catalog_items
        @items = @catalog_items.select { |t| t.credits >= 1 || t.virtual_credits >= 1 } - @current_event.credits
        @credit_credential = @current_event.credit_credential.reject { |_, v| v.zero? }

        @pos_views = { chart_id: "credentials_flow", cols: ["Credits"], currency: "", data: @current_event.plot(credit: crds, virtual_credit: v_crds), decimals: 2 }
      end

      def credit_box_office
        @partial = "credit/box_office"

        @stations = @current_event.stations.where(category: Event::BOX_OFFICE_STATIONS)
        @dates = @current_event.credit_box_office.reject { |_, v| v.zero? }.keys

        data = @current_event.plot(@stations.map { |station| [station.name, @current_event.credit_box_office(station_filter: station)] }.to_h)
        @pos_views = { chart_id: "box_office_flow", cols: [@current_event.currency_symbol], currency: @current_event.currency_symbol, data: data, metric: [@current_event.currency_symbol], decimals: 2 }
      end

      def credit_onsite_refunds
        @partial = "credit/onsite_refunds"

        @stations = @current_event.stations.where(category: Event::TOPUPS_STATIONS).reject { |station| @current_event.credit_onsite_refunds_total(station_filter: station).zero? }
        @refunds = @current_event.credit_onsite_refunds(credit_filter: @credits, station_filter: @stations).reject { |_, v| v.zero? }

        crds = @current_event.credit_onsite_refunds_base(grouping: :hour, credit_filter: @credit, station_filter: @stations)
        @pos_views = { chart_id: "onsite_refunds_flow", cols: ["Credits"], currency: "", data: @current_event.plot(credit: crds), decimals: 2 }
      end

      def credit_online_refunds
        @partial = "credit/online_refunds"

        crds = @current_event.credit_online_refunds_base(grouping: :hour, credit_filter: [@credit], payment_filter: @filter)
        @pos_views = { chart_id: "online_refunds_flow", cols: ["Credits"], currency: "", data: @current_event.plot(credit: crds), decimals: 2 }
      end

      def credit_outcome_fees
        @partial = "credit/outcome_fees"

        @stations = @current_event.stations.where(category: Event::TOPUPS_STATIONS).select { |station| station.pokes.where(action: 'fee').positive? }
        @fees = @current_event.credit_outcome_fees(credit_filter: @credits, station_filter: @stations).reject { |_, v| v.zero? }

        crds = @current_event.credit_outcome_fees(grouping: :hour, credit_filter: [@credit])
        @pos_views = { chart_id: "outcome_fees_flow", cols: ["Credits"], currency: "", data: @current_event.plot(credit: crds), decimals: 2 }
      end

      def credit_income_fees
        @partial = "credit/income_fees"

        @stations = @current_event.stations.where(category: "top_up_refund")
        @dates = @current_event.credit_outcome_fees(credit_filter: @credits).reject { |_, v| v.zero? }.keys

        crds = @current_event.credit_outcome_fees(grouping: :hour, credit_filter: @credits)
        @pos_views = { chart_id: "outcome_fees_flow", cols: ["Credits"], currency: "", data: @current_event.plot(credits: crds), decimals: 2 }
      end

      def credit_outcome_orders
        @partial = "credit/outcome_orders"

        @gateways = @current_event.credit_outcome_online_orders.select(:gateway).distinct.pluck(:gateway)

        data = @gateways.map { |gateway| [gateway.underscore, @current_event.credit_online_orders_outcome(grouping: :hour, credit_filter: @credits, payment_filter: gateway)] }.to_h
        @pos_views = { chart_id: "orders_flow", cols: ["Credits"], currency: "", data: @current_event.plot(data), decimals: 2 }
      end

      def money_topups
        @partial = "money/topups"

        @stations = @current_event.stations.where(category: "top_up_refund")
        @topups = @current_event.money_topups.reject { |_, sum| sum.zero? }
        @payments = @current_event.monetary_topups.distinct.pluck(:payment_method)

        @cash_recon = @current_event.cash_recon.order(:date)

        data = @current_event.plot(@payments.map { |payment| [payment.underscore, @current_event.money_topups(payment_filter: payment)] }.to_h)
        @pos_views = { chart_id: "topups_flow", cols: [@current_event.currency_symbol], currency: @current_event.currency_symbol, data: data, metric: [@current_event.currency_symbol], decimals: 2 }
      end

      def money_orders
        @partial = "money/orders"

        @orders = @current_event.money_online_orders_base.reject { |_, v| v.zero? }
        @gateways = @current_event.online_orders.distinct.pluck(:gateway)

        data = @current_event.plot(@gateways.map { |gateways| [gateways.underscore, @current_event.money_online_orders_base(payment_filter: gateways)] }.to_h)
        @pos_views = { chart_id: "orders_flow", cols: [@current_event.currency_symbol], currency: @current_event.currency_symbol, data: data, metric: [@current_event.currency_symbol], decimals: 2 }
      end

      def money_box_office
        @partial = "money/box_office"

        @items = @current_event.catalog_items.where(id: @current_event.monetary_box_office.select(:catalog_item_id).distinct.pluck(:catalog_item_id))
        @payments = @current_event.monetary_box_office.select(:payment_method).distinct.pluck(:payment_method)
        @dates = @current_event.money_box_office.reject { |_, v| v.zero? }.keys

        data = @current_event.plot(@items.map { |item| [item.name.underscore, @current_event.money_box_office(catalog_filter: item)] }.to_h)
        @pos_views = { chart_id: "box_office_flow", cols: [@current_event.currency_symbol], currency: @current_event.currency_symbol, data: data, metric: [@current_event.currency_symbol], decimals: 2 }
      end

      def money_fees
        @partial = "money/fees"

        @fees = @current_event.money_income_fees
        @payments = @current_event.online_payment_methods
        @dates = @fees.reject { |_, sum| sum.zero? }.keys.sort

        data = @current_event.plot(@payments.map { |payments| [payments.underscore, @current_event.money_income_fees(payment_filter: payments)] }.to_h)
        @pos_views = { chart_id: "topups_flow", cols: [@current_event.currency_symbol], currency: @current_event.currency_symbol, data: data, metric: [@current_event.currency_symbol], decimals: 2 }
      end

      def money_online_refunds
        @partial = "money/online_refunds"

        @refunds = @current_event.money_online_refunds_base.reject { |_, v| v.zero? }
        @gateways = @current_event.online_refunds(payment_filter: @filter).distinct.pluck(:gateway)

        data = @current_event.plot(@gateways.map { |gateway| [gateway.to_sym, @current_event.money_online_refunds_base(payment_filter: gateway)] }.to_h)
        @pos_views = { chart_id: "box_office_flow", cols: [@current_event.currency_symbol], currency: @current_event.currency_symbol, data: data, metric: [@current_event.currency_symbol], decimals: 2 }
      end

      def money_onsite_refunds
        @partial = "money/onsite_refunds"

        @stations = @current_event.stations.where(category: Event::TOPUPS_STATIONS).reject { |station| @current_event.money_onsite_refunds_total(station_filter: station).zero? }
        @refunds = @current_event.money_onsite_refunds(station_filter: @stations).reject { |_, v| v.zero? }
        @payments = @current_event.monetary_topups.distinct.pluck(:payment_method)

        data = @current_event.plot(@payments.map { |payment| [payment, @current_event.money_onsite_refunds(payment_filter: payment)] }.to_h)
        @pos_views = { chart_id: "box_office_flow", cols: [@current_event.currency_symbol], currency: @current_event.currency_symbol, data: data, metric: [@current_event.currency_symbol], decimals: 2 }
      end

      def money_income_fees
        @partial = "money/income_fees"

        orders_fees = @current_event.money_online_orders_fee(grouping: :day).reject { |_, v| v.zero? }
        refunds_fees = @current_event.money_online_refunds_fee(grouping: :day).reject { |_, v| v.zero? }

        data = @current_event.plot(online_topups: orders_fees, online_refunds: refunds_fees)
        @pos_views = { chart_id: "box_office_flow", cols: [@current_event.currency_symbol], currency: @current_event.currency_symbol, data: data, metric: [@current_event.currency_symbol], decimals: 2 }
      end

      def check_request_format
        return if request.format.js?
        flash.now[:alert] = 'Unable to open in a new tab'

        respond_to do |format|
          format.html { render action: :show }
        end
      end

      def prepare_view(name)
        @name = name
        respond_to do |format|
          format.js { render action: :load_view }
        end
      end

      def authorize_billing
        authorize(@current_event, :analytics?)
        @load_analytics_resources = true
        @credit_value = @current_event.credit.value
        @credit_name = @current_event.credit.name
        @customers = @current_event.customers.count - @current_event.customers.where(operator: true).count
      end

      def analytics_params
        params.require(:analytics).permit(:data, :selected, filter: {})
      end
    end
  end
end
