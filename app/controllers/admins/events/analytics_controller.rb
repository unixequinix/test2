module Admins
  module Events
    class AnalyticsController < Admins::Events::BaseController
      include EventsHelper
      include AnalyticsHelper

      before_action :authorize_billing
      before_action :load_credits, only: %i[cashless partner_reports]
      before_action :load_money, only: %i[money partner_reports]
      before_action :load_kpis, only: %i[show partner_reports]

      def show # rubocop:disable Metrics/AbcSize
        @message = analytics_message(@current_event)
        totals = {}
        totals[:subtotals] = { money: {}, credits: {} }

        orders_dashboard = Order.dashboard(@current_event)
        tickets_dashboard = Ticket.dashboard(@current_event)
        pokes_dashboard = Poke.dashboard(@current_event)
        refunds_dashboard = Refund.dashboard(@current_event)
        refunds_dashboard[:money_reconciliation] = refunds_dashboard[:outstanding_credits].to_f * @credit_value
        kpis = [orders_dashboard, tickets_dashboard, pokes_dashboard, refunds_dashboard]

        @kpis = formater(grouper(kpis))

        totals[:totals_pokes] = Poke.totals(@current_event)
        totals[:totals_orders] = Order.totals(@current_event)
        totals[:totals_refunds] = Refund.totals(@current_event)
        totals[:totals_tickets] = Ticket.totals(@current_event)

        source_action_money = totals[:totals_pokes][:source_action_money] + totals[:totals_orders][:source_action_money] + totals[:totals_refunds][:source_action_money]
        totals[:subtotals][:money_highlight] = transformer(source_action_money.map { |t| { "dm1" => t['action'], "dm2" => t['source'], "metric" => t['money'] } }, "currency", @customers).sort_by { |t| -t["t"] }
        source_payment_method_money = totals[:totals_pokes][:source_payment_method_money] + totals[:totals_orders][:source_payment_method_money] + totals[:totals_refunds][:source_payment_method_money]
        totals[:subtotals][:money][:money_by_payment_method] = transformer(source_payment_method_money.map { |t| { "dm1" => t['source'], "dm2" => t['payment_method'], "metric" => t['money'] } }, "currency", @customers).sort_by { |t| -t["t"] }

        totals[:totals_pokes][:event_day_money] = PokesQuery.new(@current_event).event_day_money
        totals[:totals_pokes][:d_credits] = PokesQuery.new(@current_event).credits_flow_day

        totals[:totals_refunds][:credit_breakage] = totals[:totals_refunds][:credit_breakage].each { |o| o["credit_name"] = @credit_name }
        credit_breakage = totals[:totals_pokes][:credit_breakage] + totals[:totals_orders][:credit_breakage] + totals[:totals_tickets][:credit_breakage] + totals[:totals_refunds][:credit_breakage]
        credit_breakage = credit_breakage.map { |t| { t["credit_name"] => t["credit_amount"] } }
        totals[:credit_breakage] = grouper(credit_breakage)
        totals[:totals_refunds][:credits_type] = totals[:totals_refunds][:credits_type].each { |o| o["credit_name"] = @credit_name }
        credits_type = totals[:totals_pokes][:credits_type] + totals[:totals_orders][:credits_type] + totals[:totals_tickets][:credits_type] + totals[:totals_refunds][:credits_type]
        totals[:subtotals][:credits][:credits_type] = transformer(credits_type.map { |t| { "dm1" => t['action'], "dm2" => t['credit_name'], "metric" => t['credit_amount'] } }, "token", @customers).sort_by { |t| -t["t"] }
        @totals = totals
      end

      def key_metrics
        metrics = JSON.parse(PokesQuery.new(@current_event).key_metrics_by_day)
        @views = { chart_id: "key_metrics", title: "Key Metrics", cols: ["Amount"], currency: @current_event.currency_symbol, data: metrics, metric: ["Money"], decimals: 1 }
        @redirect = 'admins/events/analytics/key_metric'
        prepare_data(params["action"])
      end

      def partner_reports
        @totals = @kpis
        cols = ['Description', 'Location', 'Station Type', 'Station Name', 'Product Name', 'Event Day', 'Date Time', 'Operator UID', 'Operator Name', 'Device', 'Credit Name', 'Credits']
        sales = prepare_pokes(cols, @current_event.pokes.products_sale.as_json)
        top_cols = ['Product Name', 'Credits', 'sorter']
        top_products = prepare_pokes(top_cols, @current_event.pokes.top_products.as_json)
        @views = [
          { chart_id: "money_flow", title: "Money Flow", cols: ["Event Day"], rows: ["Action"], data: @money, metric: ["Money"], decimals: 1 },
          { chart_id: "money_recon", title: "Money Reconciliation Summary", cols: ["Payment Method"], rows: ["Action", "Station Name"], data: @money, metric: ["Money"], decimals: 1 },
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
          { chart_id: "sales_perfourmance", title: "Sales Perfourmance by Hour", cols: ["Date Time"], rows: ["Station Name"], data: sales, metric: ["Credits"], decimals: 1, partial: "chart_card", type: "Stacked Bar Chart" }

        ]

        prepare_data(params["action"])
      end

      def money
        totals = Poke.money_dashboard(@current_event)
        totals = totals.merge(Order.money_dashboard(@current_event))
        totals[:online_refunds] = @current_event.refunds.completed.sum(:credit_base) * @credit_value
        totals[:money_reconciliation] = totals[:money_reconciliation] + totals[:income_online] - totals[:online_refunds]
        @totals = totals.reject { |_k, v| v.zero? }.map { |k, v| [k, number_to_event_currency(v)] }

        @views = [
          { chart_id: "money", title: "Money Flow", cols: ["Payment Method"], rows: ["Action"], data: @money, metric: ["Money"], decimals: 1 },
          { chart_id: "money_by_stations", title: "Money Flow by Stations", cols: ["Event Day", "Payment Method"], rows: ["Location", "Station Type", "Station Name", "Action"], data: @money, metric: ["Money"], decimals: 1 }
        ]
        prepare_data(params["action"])
      end

      def cashless # rubocop:disable Metrics/AbcSize
        ticket_credits = @current_event.ticket_types.map { |tt| [tt.catalog_item_id, (tt.catalog_item.credits + tt.catalog_item.virtual_credits)] }.to_h

        totals = Poke.credit_dashboard(@current_event)
        totals = totals.merge(Order.credit_dashboard(@current_event))
        totals[:online_refunds] = @current_event.refunds.completed.sum(:credit_base)
        totals[:ticket_credits] = @current_event.tickets.where.not(customer_id: nil).map { |t| ticket_credits[t.ticket_type_id].to_f }.sum
        totals[:orders_fees] = totals[:orders_fees] / @credit_value
        totals[:outstanding_credits] = (totals[:outstanding_credits].to_f + totals[:online_order_credits].to_f - totals[:online_refunds].to_f + totals[:ticket_credits].to_f + totals[:orders_fees].to_f)
        totals[:fees] = totals[:fees] + totals[:orders_fees]
        totals.delete(:orders_fees)
        @totals = totals.reject { |_k, v| v.zero? }.map { |k, v| [k, number_to_token(v)] }

        @views = [
          { chart_id: "credits", title: "Credit Flow", cols: ["Event Day", "Credit Name"], rows: %w[Action Description], data: @credits, metric: ["Credits"], decimals: 1 },
          { chart_id: "credits_detail", title: "Credit Flow by Station", cols: ["Event Day", "Credit Name"], rows: ["Location", "Action", "Station Type", "Station Name"], data: @credits, metric: ["Credits"], decimals: 1 }
        ]
        prepare_data(params["action"])
      end

      def sales
        sale_credit = -@current_event.pokes.where(credit: @current_event.credit).sales.is_ok.sum(:credit_amount)
        sale_virtual = -@current_event.pokes.where(credit: @current_event.virtual_credit).sales.is_ok.sum(:credit_amount)
        total_sale = -@current_event.pokes.where(credit: @current_event.credits).sales.is_ok.sum(:credit_amount)

        cols = ["Description", "Location", "Station Type", "Station Name", "Product Name", "Credit Name", "Credits", "Event Day", "Operator UID", "Operator Name", "Device"]
        products = prepare_pokes(cols, @current_event.pokes.products_sale.as_json)

        @totals = { sale_credit: sale_credit, sale_virtual: sale_virtual, total_sale: total_sale }.map { |k, v| [k, number_to_token(v)] }
        @views = [{ chart_id: "products", title: "Products Sale", cols: ["Event Day", "Credit Name"], rows: ["Location", "Station Type", "Station Name"], data: products, metric: ["Credits"], decimals: 1 }]
        prepare_data(params["action"])
      end

      def gates
        total_checkins = @current_event.tickets.where(redeemed: true).count
        total_access = @current_event.pokes.sum(:access_direction)
        activations = @current_event.customers.count
        staff = @current_event.customers.where(operator: true).count

        rate_cols = ["Ticket Type", "Total Tickets", "Redeemed"]
        checkin_rate = prepare_pokes(rate_cols, @current_event.ticket_types.checkin_rate.as_json)
        ticket_cols = ["Action", "Description", "Location", "Station Type", "Station Name", "Catalog Item", "Ticket Type", "Total Tickets", "Event Day", "Operator UID", "Operator Name", "Device"]
        checkin_ticket_type = prepare_pokes(ticket_cols, @current_event.pokes.checkin_ticket_type.as_json)
        access_cols = ["Location", "Station Type", "Station Name", "Event Day", "Date Time", "Direction", "Access"]
        access_control = prepare_pokes(access_cols, @current_event.pokes.access.as_json)

        @totals = { total_checkins: total_checkins, total_access: total_access, activations: activations, staff: staff }.map { |k, v| [k, v.to_i] }
        @views = [{ chart_id: "checkin_rate", title: "Ticket Check-in Rate", cols: [], rows: ["Ticket Type", "Redeemed"], data: checkin_rate, metric: ["Total Tickets"], decimals: 0 },
                  { chart_id: "checkin_ticket_type", title: "Check-in and Box office purchase", cols: ["Event Day"], rows: ["Station Name", "Catalog Item"], data: checkin_ticket_type, metric: ["Total Tickets"], decimals: 0 },
                  { chart_id: "access_control", title: "Access Control", cols: ["Station Name", "Direction"], rows: ["Event Day", "Date Time"], data: access_control, metric: ["Access"], decimals: 0 }]
        prepare_data(params["action"])
      end

      private

      def load_kpis
        orders_dashboard = Order.dashboard(@current_event)
        tickets_dashboard = Ticket.dashboard(@current_event)
        pokes_dashboard = Poke.dashboard(@current_event)
        refunds_dashboard = Refund.dashboard(@current_event)
        refunds_dashboard[:money_reconciliation] = refunds_dashboard[:outstanding_credits].to_f * @credit_value
        kpis = [orders_dashboard, tickets_dashboard, pokes_dashboard, refunds_dashboard]

        @kpis = formater(grouper(kpis))
      end

      def load_credits
        online_packs = Order.online_packs(@current_event).as_json
        ticket_packs = Ticket.online_packs(@current_event).as_json
        online_topup = @current_event.orders.online_topup.as_json
        order_fee = @current_event.orders.online_purchase_fee.each do |o|
          o.credit_name = @credit_name
          o.credit_amount = o.credit_amount / @credit_value
        end
        credits_onsite = @current_event.pokes.credit_flow.as_json
        credits_refunds = @current_event.refunds.online_refund_credits.each { |o| o.credit_name = @credit_name }.as_json

        credits_cols = ["Action", "Description", "Location", "Station Type", "Station Name", "Credit Name", "Credits", "Device", "Event Day", "Date Time"]
        credits = online_packs + online_topup + credits_onsite + credits_refunds + ticket_packs + order_fee
        @credits = prepare_pokes(credits_cols, credits)
      end

      def load_money
        online_purchase = @current_event.orders.online_purchase.as_json
        onsite_money = @current_event.pokes.money_recon.as_json
        online_refunds = @current_event.refunds.online_refund.each { |o| o.money = o.money * @credit_value }.as_json

        money_cols = ["Action", "Description", "Location", "Station Type", "Station Name", "Money", "Payment Method", "Event Day", "Date Time"]
        money = onsite_money + online_purchase + online_refunds
        @money = prepare_pokes(money_cols, money)
      end

      def authorize_billing
        authorize(@current_event, :analytics?)
        @load_analytics_resources = true
        @credit_value = @current_event.credit.value
        @credit_name = @current_event.credit.name
        @customers = @current_event.customers.count - @current_event.customers.where(operator: true).count
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
