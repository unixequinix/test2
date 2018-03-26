module AnalyticsHelper
  include ApplicationHelper
  include ActiveSupport::NumberHelper

  def prepare_pokes(atts, data)
    data.map { |poke| PokeSerializer.new(poke).to_h.slice(*atts) }.to_json
  end

  def prep(atts, data)
    data.map { |poke| PokeSerializer.new(poke).to_h.slice(*atts) }
  end

  def grouper(array)
    array.inject { |memo, el| memo.merge(el) { |_k, old_v, new_v| old_v.to_f + new_v.to_f } } || []
  end

  def formatter(data)
    {
      money_reconciliation: number_to_event_currency(data[:money_reconciliation]),
      outstanding_credits: number_to_token(data[:outstanding_credits]),
      total_sales: number_to_token(data[:total_sales]),
      activations: data[:activations].to_i
    }
  end

  def analytics_cards(event, key) # rubocop:disable Metrics/AbcSize
    credit = event.credit
    credit_value = credit.value
    event_currency_symbol = event.currency_symbol
    onsite_topups = event.pokes.where(action: 'topup', payment_method: %w[card cash]).is_ok.as_json
    online_orders = Order.credit_dashboard(@current_event).as_json

    # Topups
    online_credit_topups_money = event.orders.completed.pluck(:money_base, :money_fee).flatten.sum
    onsite_topups_money = onsite_topups.map { |topup| topup['monetary_total_price'] * credit_value }.sum

    # Sales
    sales = event.pokes.where(action: 'sale', credit: credit).is_ok.includes(:station)
    sales_money = sales.sum(:credit_amount)

    # Refunds
    online_refunds = event.refunds.completed.sum(:credit_base) * credit_value
    onsite_refunds = event.pokes.where(action: 'refund').is_ok.sum(:monetary_total_price)
    refunds_money = online_refunds + onsite_refunds

    # Customers
    customers = event.customers

    # Purchasers
    purchasers_money = event.pokes.where(action: 'purchase').is_ok.sum(:monetary_total_price)

    # Spending Power
    ticket_type_credits = event.ticket_types.includes(:catalog_item).where.not(catalog_item_id: nil).map { |tt| [tt.id, tt.catalog_item.credits] }.to_h
    credential_sp = event.tickets.with_customer.unredeemed.pluck(:ticket_type_id).map { |tt_id| ticket_type_credits[tt_id].to_f }.sum + event.gtags.with_customer.unredeemed.pluck(:ticket_type_id).map { |tt_id| ticket_type_credits[tt_id].to_f }.sum
    order_sp = OrderItem.where(order: event.orders.completed, redeemed: false, catalog_item: event.credit).sum(:amount)
    refund_sp = event.refunds.completed.pluck(:credit_base, :credit_fee).flatten.sum
    gtag_sp = event.gtags.where(active: true).sum(:credits)
    total_sp = (credential_sp + order_sp + refund_sp + gtag_sp) * credit_value
    online_sp = (credential_sp + order_sp + refund_sp) * credit_value
    onsite_sp = gtag_sp * credit_value

    topups_by_source = [online: online_credit_topups_money, onsite: onsite_topups_money]
    purchasers_by_source = [online: 0, onsite: purchasers_money]

    total_income = (topups_by_source + purchasers_by_source).map { |item| item[:online].to_i + item[:onsite].to_i }.sum
    onsite_income = (topups_by_source + purchasers_by_source).map { |item| item[:onsite].to_i }.sum
    online_income = (total_income - onsite_income)
    total_outstanding = total_income.abs - sales_money.abs - refunds_money.abs
    onsite_outstanding = onsite_income.abs - sales_money.abs - onsite_refunds.abs
    online_outstanding = total_outstanding.abs - onsite_outstanding.abs

    data = {
      dashboard: {
        topups: {
          colors: ['#009688', '#66FF99'],
          icon: 'attach_money',
          title: { text: "Total Topups in #{event_currency_symbol}", number: number_to_reports(online_credit_topups_money + onsite_topups_money) },
          subtitle: [
            { text: 'Online', number: number_to_reports(online_credit_topups_money) },
            { text: 'Onsite', number: number_to_reports(onsite_topups_money) }
          ]
        },
        sales: {
          colors: ['#FF4E50', '#F9D423'],
          icon: 'equalizer',
          title: { text: "Total Sales in #{event_currency_symbol}", number: number_to_reports(sales_money.to_f.abs) },
          subtitle: [
            { text: 'At Bars', number: number_to_reports(sales.where(stations: { category: 'bar' }).sum(:credit_amount).to_f.abs) },
            { text: 'At vendors', number: number_to_reports(sales.where(stations: { category: 'vendor' }).sum(:credit_amount).to_f.abs) }
          ]
        },
        products: {
          colors: ['#514A9D', '#24C6DC'],
          icon: 'add_shopping_cart',
          title: { text: 'Total Products Sold', number: sales.where("credit_amount < 0").count },
          subtitle: [
            { text: 'At Bars', number: number_with_delimiter(sales.where(stations: { category: 'bar' }).where("credit_amount < 0").count) },
            { text: 'At vendors', number: number_with_delimiter(sales.where(stations: { category: 'vendor' }).where("credit_amount < 0").count) }
          ]
        },
        activations: {
          colors: ['#FF0066', '#FF9999'],
          icon: 'touch_app',
          title: { text: 'Total Activations', number: number_with_delimiter(customers.count) },
          subtitle: [
            { text: 'Customers', number: number_with_delimiter(customers.where(operator: false).count) },
            { text: 'Staff', number: number_with_delimiter(customers.where(operator: true).count) }
          ]
        },
        tickets_and_orders: {
          colors: ['#F2F2F2', '#F2F2F2'],
          data: {
            tickets: { text: 'Tickets Checked In / Tickets in System', current: number_with_delimiter(event.tickets.where(redeemed: true).count), total: number_with_delimiter(event.tickets.count) },
            orders: { text: "Orders Redeemed / Orders in System", current: number_to_event_currency(online_orders["online_order_credits"].to_f - online_orders["unreedemed_online_order_credits"].to_f), total: number_to_event_currency(online_orders["online_order_credits"].to_f) }
          }
        },
        gtags: {
          colors: ['#FF5050', '#F3A183'],
          icon: 'loyalty',
          title: { text: "Potential Spending in #{event_currency_symbol}", number: number_to_reports(total_sp) },
          subtitle: [
            { text: 'Online', number: number_to_reports(online_sp) },
            { text: 'Onsite', number: number_to_reports(onsite_sp) }
          ]
        },
        customers: {
          colors: ['#355C7D', '#C06C84'],
          icon: 'supervisor_account',
          title: { text: 'Spending Customers', number: number_with_delimiter(sales.select(:customer_id).distinct.count) },
          subtitle: [
            { text: 'Average Spend per Customer', number: number_to_event_currency(sales.sum(:credit_amount).abs / (sales.select(:customer_id).distinct.count.nonzero? || 1)) }
          ]
        }
      },
      key_metrics: {
        total_income: {
          colors: ['#1A2980', '#26D0CE'],
          icon: 'input',
          title: { text: 'Cash In', number: number_to_reports(total_income) },
          subtitle: { online: number_to_reports(online_income), onsite: number_to_reports(onsite_income), total: number_to_reports(total_income) },
          tooltip: { id: 'income', title: 'Income includes: ', text: ['Orders', 'Topups', 'Box Office'] }
        },
        total_sales: {
          colors: ['#FF4E50', '#F9D423'],
          icon: 'equalizer',
          title: { text: 'Sales', number: number_to_reports(sales_money.abs) },
          subtitle: { online: "-", onsite: number_to_reports(sales_money.abs), total: number_to_reports(sales_money.abs) }
        },
        total_refunds: {
          colors: ['#FF5050', '#F3A183'],
          icon: 'money_off',
          title: { text: 'Refunds', number: number_to_reports(refunds_money.abs) },
          subtitle: { online: number_to_reports(online_refunds.abs), onsite: number_to_reports(onsite_refunds.abs), total: number_to_reports(refunds_money.abs) }
        },
        outstanding: {
          colors: ['#001510', '#00bf8f'],
          icon: 'account_balance_wallet',
          title: { text: 'Outstanding', number: number_to_reports(total_outstanding) },
          subtitle: { online: number_to_reports(online_outstanding), onsite: number_to_reports(onsite_outstanding), total: number_to_reports(total_outstanding) }
        }
      }
    }

    data[key]
  end
end
