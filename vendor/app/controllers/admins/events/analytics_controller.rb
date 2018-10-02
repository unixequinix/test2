module Admins
  module Events
    class AnalyticsController < Admins::Events::BaseController
      include ActionController::Live

      include ApplicationHelper
      include AnalyticsHelper
      include Analytics::ExcelHelper

      ANALYTICS_METHODS = %w[money_topups money_orders money_box_office money_online_refunds money_onsite_refunds money_topup_fees money_refund_fees credit_topups credit_sales credit_orders credit_orders_tokens credit_credentials credit_credentials_tokens credit_box_office credit_onsite_refunds credit_online_refunds credit_onsite_refund_fees credit_fees credit_outcome_orders credit_outcome_orders_tokens].map { |s| [s.to_sym, s.to_sym] }.to_h.freeze

      before_action :set_credits
      before_action :authorize_analytics, except: %i[show]

      def show
        authorize(@current_event, :analytics?)
      end

      def dashboard
        cookies.delete :analytics_credit_report
        sales = @current_event.credit_sales(grouping: :hour)
        topups = @current_event.credit_topups(grouping: :hour)
        refunds = @current_event.credit_refunds(grouping: :hour)
        @pos_views = { cols: ["Credits"], currency: "", data: @current_event.plot(sales: sales, topups: topups, refunds: refunds), decimals: 2 }

        @partial = 'admins/events/analytics/dashboard'
        prepare_view(params[:action])
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
        cookies.delete :analytics_token_filter
        @selected_report = cookies.signed[:analytics_credit_report]
        @credits = params[:credit_filter].present? ? @current_event.catalog_items.credits.where(id: params[:credit_filter]) : (@current_event.credits.where(id: cookies.signed[:analytics_credit_filter]).presence || @current_event.credits)
        cookies.signed[:analytics_credit_filter] = @credits.pluck(:id)

        @credit_income = @current_event.credit_income(credit_filter: @credits)
        @credit_sales = @current_event.credit_sales(credit_filter: @credits)
        @credit_refunds = @current_event.credit_refunds(credit_filter: @credits)

        metrics = @current_event.plot(income: @credit_income, sales: @credit_sales, refunds: @credit_refunds)

        @views = { chart_id: "cash_flow", title: "Cash Flow", cols: ["Amount"], currency: @current_event.currency_symbol, data: metrics, metric: ["Credits"], decimals: 1 }
        @partial = 'admins/events/analytics/credits_flow'
        prepare_view(params[:action])
      end

      def tokens_flow
        @selected_report = cookies.signed[:analytics_token_report]
        @credits = params[:token_filter].present? ? @current_event.tokens.where(id: params[:token_filter]) : (@current_event.tokens.where(id: cookies.signed[:analytics_token_filter]).presence || @current_event.tokens)
        cookies.signed[:analytics_token_filter] = @credits.pluck(:id)

        @credit_income = @current_event.token_income(credit_filter: @credits)
        @credit_sales = @current_event.credit_sales(credit_filter: @credits)
        @credit_refunds = @current_event.credit_refunds(credit_filter: @credits)

        metrics = @current_event.plot(income: @credit_income, sales: @credit_sales, refunds: @credit_refunds)
        @views = { chart_id: "cash_flow", title: "Cash Flow", cols: ["Amount"], currency: @current_event.currency_symbol, data: metrics, metric: ["Credits"], decimals: 1 }
        @partial = 'admins/events/analytics/tokens_flow'
        prepare_view(params[:action])
      end

      def checkin
        cookies.delete :analytics_credit_report
        @filter = params[:filter] || 'stations'
        @partial = "admins/events/analytics/checkin_#{@filter}"

        @checkins = @current_event.count_checkins
        @items = @current_event.catalog_items.where(id: @current_event.ticket_types.select(:catalog_item_id).distinct.pluck(:catalog_item_id)).order(:type, :name)
        @stations = @current_event.stations.where(id: @current_event.checkins.select(:station_id).distinct.pluck(:station_id)).order(:category, :name)
        @dates = @checkins.reject { |_, v| v.zero? }.keys

        data = @current_event.plot(checkins: @current_event.count_checkins(grouping: :hour))
        @views = { chart_id: "checkins_flow", cols: ["Amount"], currency: "", data: data, decimals: 0 }
        @pdf_title = params[:station_category]

        respond_to do |format|
          format.html { prepare_view(params[:action]) }
          format.js { prepare_view(params[:action]) }
          format.xls { handle_response(@current_event, @current_event.checkins, response, @partial) }
          format.pdf { analytics_pdf("#{@pdf_title&.humanize}.pdf", "admins/events/analytics/" + "_" + @pdf_title.to_s + ".html", "Stations/" + @pdf_title.to_s, @dates.count) }
        end
      end

      def engagement
        cookies.delete :analytics_credit_report
        @partial = "admins/events/analytics/engagement"

        @engagement = @current_event.count_engagement
        @stations = @current_event.stations.where(id: @current_event.engagement.select(:station_id).distinct.pluck(:station_id)).order(:category, :name)
        @dates = @engagement.reject { |_, v| v.zero? }.keys

        data = @current_event.plot(engagement: @current_event.count_engagement(grouping: :hour))
        @views = { chart_id: "engagement_flow", cols: ["Amount"], currency: "", data: data, decimals: 0 }
        @pdf_title = "engagement"

        respond_to do |format|
          format.html { prepare_view(params[:action]) }
          format.js { prepare_view(params[:action]) }
          format.xls { handle_response(@current_event, @current_event.engagement, response, @partial) }
          format.pdf { analytics_pdf("#{@pdf_title&.humanize}.pdf", "admins/events/analytics/" + "_" + @pdf_title.to_s + ".html", "Stations/" + @pdf_title.to_s, @dates.count) }
        end
      end

      def access_control
        cookies.delete :analytics_credit_report
        @filter = params[:filter] || 'stations'
        @partial = "admins/events/analytics/access_#{@filter}"
        @checkpoints = @current_event.count_checkpoints
        @items = @current_event.catalog_items.where(id: @current_event.checkpoints.select(:catalog_item_id).distinct.pluck(:catalog_item_id)).order(:type, :name)
        @stations = @current_event.stations.where(id: @current_event.checkpoints.select(:station_id).distinct.pluck(:station_id)).order(:category, :name)
        @dates = @checkpoints.reject { |_, v| v.zero? }.keys

        data = @current_event.plot(checkpoints: @current_event.count_checkpoints(grouping: :hour))
        @views = { chart_id: "checkpoints_flow", cols: ["Amount"], currency: "", data: data, decimals: 0 }

        @pdf_title = params[:station_category]

        respond_to do |format|
          format.html { prepare_view(params[:action]) }
          format.js { prepare_view(params[:action]) }
          format.xls { handle_response(@current_event, @current_event.checkpoints, response, @partial) }
          format.pdf { analytics_pdf("#{@pdf_title&.humanize}.pdf", "admins/events/analytics/" + "_" + @pdf_title.to_s + ".html", "Stations/" + @pdf_title.to_s, @dates.count) }
        end
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
        top_products = prepare_pokes(cols, @current_event.pokes.top_products(@current_event.credits).as_json)
        @views = [
          { chart_id: "money_recon", title: "Money Reconciliation Summary", cols: ["Payment Method"], rows: ["Action", "Station Name"], data: @money, metric: ["Money"], decimals: 1 },
          { chart_id: "money_flow", title: "Money Flow", cols: ["Event Day"], rows: ["Action"], data: @money, metric: ["Money"], decimals: 1 },
          { chart_id: "topups_statiom", title: "Topup-Refund by Hour / Station", cols: ["Date Time"], rows: ["Station Name"], data: @money, metric: ["Money"], decimals: 1, partial: "chart_card", type: "Stacked Bar Chart" },
          { chart_id: "topups_payment", title: "Topup-Refund Cash / Card / Virtual by Hour", cols: ["Date Time"], rows: ["Payment Method"], data: @money, metric: ["Money"], decimals: 1, partial: "chart_card", type: "Bar Chart" },
          { chart_id: "topups_popular", title: "Most Popular Top-Up Amounts", cols: [], rows: ["Amount"], data: PokesQuery.new(@current_event).top_topup, metric: ["Customers"], decimals: 0, partial: "chart_card", type: "Bar Chart" },
          { chart_id: "customer_topup", title: "Customer Topups", partial: "admins/events/analytics/shared/doughnut_card", cols: "Avg. Topup", data: PokesQuery.new(@current_event).customer_topup },
          { chart_id: "refund_popular", title: "Most Popular Refund Amounts", cols: [], rows: ["Amount"], data: PokesQuery.new(@current_event).top_refund, metric: ["Customers"], decimals: 0, partial: "chart_card", type: "Bar Chart" },
          { chart_id: "high_sales", title: "High-Level Sale", cols: ["Credit Name"], rows: ["Station Name"], data: sales, metric: ["Credits"], decimals: 1 },
          { chart_id: "high_sales_chart", title: "Total Sales by Hour", cols: ["Date Time"], rows: ["Station Type"], data: sales, metric: ["Credits"], decimals: 1, partial: "chart_card", type: "Stacked Bar Chart" },
          { chart_id: "top_sales_amount", title: "Top 10 Product Sales (Amount)", cols: ["sorter", "Product Name"], rows: [], data: top_products, metric: ["Credits"], decimals: 1, partial: "chart_card", type: "Horizontal Bar Chart" },
          { chart_id: "top_sales_quantity", title: "Top 10 Product Sales (Quantity)", cols: ["sorter", "Product Name"], rows: [], data: PokesQuery.new(@current_event).top_product_quantity, metric: ["Quantity"], decimals: 0, partial: "chart_card", type: "Horizontal Bar Chart" },
          { chart_id: "spending_customer", title: "Customer Spending Distribution", cols: [], rows: ["Spent amount"], data: PokesQuery.new(@current_event).spending_customer, metric: ["Customers"], decimals: 0, partial: "chart_card", type: "Bar Chart" },
          { chart_id: "topups_perfourmance", title: "Topup-Refund Perfourmance by Hour", cols: ["Date Time"], rows: ["Station Name"], data: @money, metric: ["Money"], decimals: 1, partial: "chart_card", type: "Stacked Bar Chart" },
          { chart_id: "sales_perfourmance", title: "Sales Performance by Hour", cols: ["Date Time"], rows: ["Station Name"], data: sales, metric: ["Credits"], decimals: 1, partial: "chart_card", type: "Stacked Bar Chart" }
        ]
        @partial = 'admins/events/analytics/view'

        prepare_view(params[:action])
      end

      def custom_lambeth
        @p = @current_event.customers.ransack(params[:p])
        @q = @current_event.customers.ransack(params[:q])
        @access = @current_event.accesses.find_by(id: @current_event.voucher_id)

        if @access.nil?
          flash[:alert] = "Parking access must be set in voucher_id"
        else
          pokes = @current_event.pokes.where(action: 'checkpoint', catalog_item_id: @access.id).includes(:customer).order(date: :asc)
          @control_gates_in = pokes.where(customer: @p.result).group_by(&:customer).map { |_, pks| pks.last if pks.last.access_direction.eql?(1) }.flatten.compact
          @control_gates_out = pokes.where(customer: @q.result).group_by(&:customer).map { |_, pks| pks.last if pks.last.access_direction.eql?(-1) }.flatten.compact
        end
        @partial = 'admins/events/analytics/custom_lambeth'
        prepare_view(params[:action])
      end

      def custom_seasplash
        @stations = @current_event.stations.where(category: %w[bar vendor])
        @pos_stats = @current_event.credit_sales(station_filter: @stations).reject { |_k, v| v.zero? }
        @partial = 'admins/events/analytics/custom_seasplash'

        prepare_view(params[:action])
      end

      def custom_voucher
        @stations = @current_event.stations.where(category: %w[bar vendor])
        @stations = @current_event.stations.where(category: %w[vendor]) if @current_event.id.eql?(439) && Rails.env.production?
        @pos_stats = @current_event.credit_voucher_sales(station_filter: @stations).reject { |_k, v| v.zero? }
        @dates = @pos_stats.keys
        @partial = 'admins/events/analytics/custom_voucher'

        prepare_view(params[:action])
      end

      def sub_report
        cookies.signed[:analytics_credit_report] = analytics_params[:selected]
        cookies.signed[:analytics_token_report] = analytics_params[:selected]

        @credit = @current_event.credit
        @virtual_credit = @current_event.virtual_credit
        @credits = cookies.signed[:analytics_token_filter].present? ? @current_event.tokens.where(id: cookies.signed[:analytics_token_filter]) : @current_event.credits
        @event_currency = @current_event.currency_symbol

        meth = ANALYTICS_METHODS[analytics_params[:data].to_sym].to_s
        meth += "_export" if request.format.symbol.eql?(:xls)
        send(meth)

        @pdf_title = @partial

        respond_to do |format|
          format.js { render action: :render_data, global: false }
          format.xls { handle_response(@current_event, @export_data, response, @partial) }
          format.pdf { analytics_pdf("#{@pdf_title.tr('/', '-')}.pdf", "admins/events/analytics/resources/" + @pdf_title.split("/").first + "/_" + @pdf_title.split("/").last + ".html", @pdf_title.humanize, @dates.count) }
        end
      end

      private

      def credit_topups
        @partial = "credit/topups"
        @stations = @current_event.stations.where(category: Event::TOPUPS_STATIONS).order(:category, :name)
        @dates = @current_event.count_topups(credit_filter: @credits).reject { |_, v| v.zero? }.keys
        crds = @current_event.credit_topups(grouping: :hour, credit_filter: @credit, station_filter: @stations)
        v_crds = @current_event.credit_topups(grouping: :hour, credit_filter: @virtual_credit, station_filter: @stations)
        data = @current_event.plot(credit: crds, virtual_credit: v_crds)
        @pos_views = { chart_id: "topups_flow", cols: ["Credits"], currency: "", data: data, decimals: 2 }
      end

      def credit_topups_export
        @partial = "credit/topups"
        @export_data = @current_event.topups(credit_filter: @credits)
      end

      def credit_sales
        @filter = analytics_params[:filter][:station_type]
        @partial = "credit/sales"

        @stations = @current_event.stations.where(category: @filter)
        @dates = @current_event.count_sales(credit_filter: @credits, station_filter: @stations).reject { |_, v| v.zero? }.keys.sort

        credits = @current_event.credit_sales(grouping: :hour, credit_filter: @credit, station_filter: @stations)
        v_credits = @current_event.credit_sales(grouping: :hour, credit_filter: @virtual_credit, station_filter: @stations)
        @pos_views = { chart_id: "sales_flow", cols: ["Credits"], currency: "", data: @current_event.plot(credit: credits, virtual_credit: v_credits), decimals: 2 }
        @top_stations = @current_event.pokes.top_stations(@filter, @credits).as_json
        @top_products = @current_event.pokes.where(station: @current_event.stations.where(category: @filter)).top_products(@credits).as_json
        non_alcohol = @current_event.pokes.where(action: "sale", product: Product.where(station: @current_event.stations, is_alcohol: false))
        alcohol = @current_event.pokes.where(action: "sale", product: Product.where(station: @current_event.stations, is_alcohol: true))
        @alcohol_products = [{ is_alcohol: "Non Alcohol", credits: -non_alcohol.sum(:credit_amount), amount: non_alcohol.count }, { is_alcohol: "Alcohol", credits: -alcohol.sum(:credit_amount), amount: alcohol.count }]
      end

      def credit_sales_export
        @partial = "credit/sales"
        @filter = analytics_params[:filter][:station_type]
        @stations = @current_event.stations.where(category: @filter)
        @export_data = @current_event.sales(credit_filter: @credits, station_filter: @stations)
      end

      def credit_orders
        @partial = "credit/orders"

        @gateways = @current_event.online_orders_income.select(:gateway).distinct.pluck(:gateway)
        @dates = @current_event.credit_online_orders_income(credit_filter: @credits).reject { |_, v| v.zero? }.keys.sort
        data = @gateways.map { |gateway| [gateway.underscore.to_sym, @current_event.credit_online_orders_income(grouping: :hour, credit_filter: @credits, payment_filter: gateway)] }.to_h
        @pos_views = { chart_id: "orders_flow", cols: ["Credits"], currency: "", data: @current_event.plot(data), decimals: 2 }
      end

      def credit_orders_tokens
        @partial = "tokens/orders"

        @gateways = @current_event.online_orders_income_tokens.select(:gateway).distinct.pluck(:gateway)
        @dates = @current_event.credit_online_orders_income(credit_filter: @credits).reject { |_, v| v.zero? }.keys.sort
        data = @gateways.map { |gateway| [gateway.underscore.to_sym, @current_event.credit_online_orders_income(grouping: :hour, credit_filter: @credits, payment_filter: gateway)] }.to_h
        @pos_views = { chart_id: "orders_flow", cols: ["Tokens"], currency: "", data: @current_event.plot(data), decimals: 2 }
      end

      def credit_orders_export
        @partial = "credit/orders"
        @export_data = @current_event.online_orders_income
      end

      def credit_credentials
        @partial = "credit/credentials"

        @catalog_items = @current_event.catalog_items
        @items = @catalog_items.select { |t| t.credits >= 1 || t.virtual_credits >= 1 } - @current_event.credits
        @dates = @current_event.credit_credential.reject { |_, v| v.zero? }.keys

        credits = @current_event.credit_credential(grouping: :hour, credit_filter: @credit)
        v_credits = @current_event.credit_credential(grouping: :hour, credit_filter: @virtual_credit)
        @pos_views = { chart_id: "credentials_flow", cols: ["Credits"], currency: "", data: @current_event.plot(credit: credits, virtual_credit: v_credits), decimals: 2 }
      end

      def credit_credentials_export
        @partial = "credit/credentials"
        @export_data = [@current_event.tickets, @current_event.gtags]
      end

      def credit_credentials_tokens
        @partial = "tokens/credentials"

        tokens = @current_event.credit_credential(grouping: :hour, credit_filter: @credits)
        @catalog_items = @current_event.catalog_items_tokens
        @items = @catalog_items.select { |_t| @current_event.tokens }
        @dates = @current_event.credit_credential(credit_filter: @credits).reject { |_, v| v.zero? }.keys

        @pos_views = { chart_id: "credentials_flow", cols: ["Credits"], currency: "", data: @current_event.plot(credit: tokens), decimals: 2 }
      end

      def credit_box_office
        @partial = "credit/box_office"

        @stations = @current_event.stations.where(category: Event::BOX_OFFICE_STATIONS)
        @dates = @current_event.count_box_office(credit_filter: @credits).reject { |_, v| v.zero? }.keys

        data = @current_event.plot(@stations.map { |station| [station.name, @current_event.credit_box_office(grouping: :hour, station_filter: station)] }.to_h)
        @pos_views = { chart_id: "box_office_flow", cols: [@current_event.currency_symbol], currency: @current_event.currency_symbol, data: data, metric: [@current_event.currency_symbol], decimals: 2 }
      end

      def credit_box_office_export
        @partial = "credit/box_office"
        @export_data = @current_event.box_office(credit_filter: @credits)
      end

      def credit_onsite_refunds
        @partial = "credit/onsite_refunds"

        @stations = @current_event.stations.where(category: Event::TOPUPS_STATIONS).reject { |station| @current_event.credit_onsite_refunds_base_total(station_filter: station).zero? }
        @dates = @current_event.credit_onsite_refunds(credit_filter: @credits, station_filter: @stations).reject { |_, v| v.zero? }.keys

        credits = @current_event.credit_onsite_refunds_base(grouping: :hour, credit_filter: @credit, station_filter: @stations)
        @pos_views = { chart_id: "onsite_refunds_flow", cols: ["Credits"], currency: "", data: @current_event.plot(credit: credits), decimals: 2 }
      end

      def credit_onsite_refunds_export
        @partial = "credit/onsite_refunds"
        @stations = @current_event.stations.where(category: Event::TOPUPS_STATIONS).reject { |station| @current_event.credit_onsite_refunds_base_total(station_filter: station).zero? }
        @export_data = @current_event.onsite_refunds(credit_filter: @credits, station_filter: @stations)
      end

      def credit_online_refunds
        @partial = "credit/online_refunds"

        @dates = @current_event.credit_online_refunds.reject { |_, v| v.zero? }.keys
        @gateways = @current_event.online_refunds(payment_filter: @filter).distinct.pluck(:gateway)

        data = @current_event.plot(@gateways.map { |gateway| [gateway.to_sym, @current_event.credit_online_refunds(grouping: :hour, payment_filter: gateway)] }.to_h)
        @pos_views = { chart_id: "online_refunds_flow", cols: [@current_event.currency_symbol], currency: @current_event.currency_symbol, data: data, metric: [@current_event.currency_symbol], decimals: 2 }
      end

      def credit_online_refunds_export
        @partial = "credit/online_refunds"
        @export_data = @current_event.online_refunds
      end

      def credit_fees
        @fee_type = params[:analytics][:filter][:fee_type]
        @partial = "credit/fees"

        @stations = @current_event.stations.where(category: Event::TOPUPS_STATIONS).select { |station| @current_event.credit_single_fee_total(station_filter: station, fee_filter: @fee_type).positive? }
        @dates = @current_event.credit_single_fee(credit_filter: @credits, station_filter: @stations, fee_filter: @fee_type).reject { |_, v| v.zero? }.keys

        credits = @current_event.credit_single_fee(grouping: :hour, credit_filter: @credit, fee_filter: @fee_type)
        @pos_views = { chart_id: "fees_flow", cols: ["Credits"], currency: "", data: @current_event.plot(credit: credits), decimals: 2 }
      end

      def credit_fees_export
        @partial = "credit/fees"
        @fee_type = params[:analytics][:filter][:fee_type]
        @stations = @current_event.stations.where(category: Event::TOPUPS_STATIONS).select { |station| @current_event.credit_single_fee_total(station_filter: station, fee_filter: @fee_type).positive? }
        @export_data = @current_event.single_fee(credit_filter: @credits, station_filter: @stations, fee_filter: @fee_type)
      end

      def credit_outcome_orders
        @partial = "credit/outcome_orders"

        @gateways = @current_event.online_orders_outcome.select(:gateway).distinct.pluck(:gateway)

        data = @gateways.map { |gateway| [gateway.underscore, @current_event.credit_online_orders_outcome(grouping: :hour, credit_filter: @credits, payment_filter: gateway)] }.to_h
        @pos_views = { chart_id: "orders_flow", cols: ["Credits"], currency: "", data: @current_event.plot(data), decimals: 2 }
      end

      def credit_outcome_orders_tokens
        @partial = "tokens/outcome_orders"

        @gateways = @current_event.online_orders_outcome_tokens.select(:gateway).distinct.pluck(:gateway)

        data = @gateways.map { |gateway| [gateway.underscore, @current_event.credit_online_orders_outcome(grouping: :hour, credit_filter: @credits, payment_filter: gateway)] }.to_h
        @pos_views = { chart_id: "orders_flow", cols: ["Credits"], currency: "", data: @current_event.plot(data), decimals: 2 }
      end

      def credit_outcome_orders_export
        @partial = "credit/outcome_orders"
        @export_data = @current_event.online_orders_outcome
      end

      def money_topups
        @partial = "money/topups"

        @stations = @current_event.stations.where(category: "top_up_refund")
        @dates = @current_event.money_topups.reject { |_, sum| sum.zero? }.keys
        @payments = @current_event.monetary_topups.distinct.pluck(:payment_method)

        @cash_recon = @current_event.cash_recon.order(:date).includes(:station, :device, :operator_gtag, :operator)

        data = @current_event.plot(@payments.map { |payment| [payment.underscore, @current_event.money_topups(grouping: :hour, payment_filter: payment)] }.to_h)
        @pos_views = { chart_id: "topups_flow", cols: [@current_event.currency_symbol], currency: @current_event.currency_symbol, data: data, metric: [@current_event.currency_symbol], decimals: 2 }
      end

      def money_topups_export
        @partial = "money/topups"
        @export_data = @current_event.monetary_topups
      end

      def money_orders
        @partial = "money/orders"

        @dates = @current_event.money_online_orders_base.reject { |_, v| v.zero? }.keys
        @gateways = @current_event.online_orders.distinct.pluck(:gateway)

        data = @current_event.plot(@gateways.map { |gateways| [gateways.underscore, @current_event.money_online_orders_base(grouping: :hour, payment_filter: gateways)] }.to_h)
        @pos_views = { chart_id: "orders_flow", cols: [@current_event.currency_symbol], currency: @current_event.currency_symbol, data: data, metric: [@current_event.currency_symbol], decimals: 2 }
      end

      def money_orders_export
        @partial = "money/orders"
        @export_data = @current_event.online_orders
      end

      def money_box_office
        @partial = "money/box_office"

        @items = @current_event.catalog_items.where(id: @current_event.monetary_box_office.select(:catalog_item_id).distinct.pluck(:catalog_item_id))
        @payments = @current_event.monetary_box_office.select(:payment_method).distinct.pluck(:payment_method)
        @dates = @current_event.count_money_box_office.reject { |_, v| v.zero? }.keys

        data = @current_event.plot(@items.map { |item| [item.name.underscore, @current_event.money_box_office(grouping: :hour, catalog_filter: item)] }.to_h)
        @pos_views = { chart_id: "box_office_flow", cols: [@current_event.currency_symbol], currency: @current_event.currency_symbol, data: data, metric: [@current_event.currency_symbol], decimals: 2 }
      end

      def money_box_office_export
        @partial = "money/box_office"
        @export_data = @current_event.monetary_box_office
      end

      def money_topup_fees
        @partial = "money/topup_fees"

        @fees = @current_event.money_online_orders_fee
        @payments = @current_event.online_payment_methods(:topups)
        @dates = @fees.reject { |_, sum| sum.zero? }.keys.sort

        data = @current_event.plot(@payments.map { |payments| [payments.underscore, @current_event.money_online_orders_fee(grouping: :hour, payment_filter: payments)] }.to_h)
        @pos_views = { chart_id: "topups_flow", cols: [@current_event.currency_symbol], currency: @current_event.currency_symbol, data: data, metric: [@current_event.currency_symbol], decimals: 2 }
      end

      def money_topup_fees_export
        @partial = "money/topup_fees"
        @export_data = @current_event.online_orders
      end

      def money_refund_fees
        @partial = "money/refund_fees"

        @fees = @current_event.money_online_refunds_fee
        @payments = @current_event.online_payment_methods(:refunds)
        @dates = @fees.reject { |_, sum| sum.zero? }.keys.sort

        data = @current_event.plot(@payments.map { |payments| [payments.underscore, @current_event.money_online_refunds_fee(grouping: :hour, payment_filter: payments)] }.to_h)
        @pos_views = { chart_id: "topups_flow", cols: [@current_event.currency_symbol], currency: @current_event.currency_symbol, data: data, metric: [@current_event.currency_symbol], decimals: 2 }
      end

      def money_refund_fees_export
        @partial = "money/refund_fees"
        @export_data = @current_event.online_refunds
      end

      def money_online_refunds
        @partial = "money/online_refunds"

        @dates = @current_event.money_online_refunds.reject { |_, v| v.zero? }.keys
        @gateways = @current_event.online_refunds(payment_filter: @filter).distinct.pluck(:gateway)

        data = @current_event.plot(@gateways.map { |gateway| [gateway.to_sym, @current_event.money_online_refunds(grouping: :hour, payment_filter: gateway)] }.to_h)
        @pos_views = { chart_id: "box_office_flow", cols: [@current_event.currency_symbol], currency: @current_event.currency_symbol, data: data, metric: [@current_event.currency_symbol], decimals: 2 }
      end

      def money_online_refunds_export
        @partial = "money/online_refunds"
        @export_data = @current_event.online_refunds(payment_filter: @filter)
      end

      def money_onsite_refunds
        @partial = "money/onsite_refunds"

        @stations = @current_event.stations.where(category: Event::TOPUPS_STATIONS).reject { |station| @current_event.money_onsite_refunds_total(station_filter: station).zero? }
        @dates = @current_event.count_money_onsite_refunds(station_filter: @stations).reject { |_, v| v.zero? }.keys
        @export_data = @current_event.monetary_onsite_refunds(station_filter: @stations)
        @payments = @current_event.monetary_topups.distinct.pluck(:payment_method)

        data = @current_event.plot(@payments.map { |payment| [payment, @current_event.money_onsite_refunds(grouping: :hour, payment_filter: payment)] }.to_h)
        @pos_views = { chart_id: "box_office_flow", cols: [@current_event.currency_symbol], currency: @current_event.currency_symbol, data: data, metric: [@current_event.currency_symbol], decimals: 2 }
      end

      def money_onsite_refunds_export
        @partial = "money/onsite_refunds"
        @stations = @current_event.stations.where(category: Event::TOPUPS_STATIONS).reject { |station| @current_event.money_onsite_refunds_total(station_filter: station).zero? }
        @export_data = @current_event.monetary_onsite_refunds(station_filter: @stations)
      end

      def prepare_view(name)
        @name = name
        respond_to do |format|
          format.js { render action: :load_view }
          format.html { render :report }
          format.xls { render "show_#{name}" }
        end
      end

      def authorize_analytics
        raise(Pundit::NotAuthorizedError) unless AnalyticsPolicy.new(@current_user, @current_event).method("#{params[:action]}?".to_sym).call

        skip_authorization
      end

      def set_credits
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
