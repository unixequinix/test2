module AnalyticsHelper
  include ApplicationHelper
  include ActiveSupport::NumberHelper

  def prepare_pokes(atts, data)
    data.map { |poke| PokeSerializer.new(poke).to_h.slice(*atts) }.to_json
  end

  def prep(atts, data)
    data.map { |poke| PokeSerializer.new(poke).to_h.slice(*atts) }
  end

  def transformer(arr, format, denominator)
    arr.map { |t| t["dm1"] }.uniq.map do |dm1|
      selected = arr.select { |t| t["dm1"] == dm1 }
      total_num = selected.map { |t| t["metric"].to_f }.compact.sum

      case format
        when "currency"
          avg = number_to_event_currency(total_num.abs / denominator)
          total = number_to_event_currency(total_num)
          dm2 = selected.map { |t| { t["dm2"] => number_to_event_currency(t["metric"]) } }
        when "token"
          avg = number_to_token(total_num.abs / denominator)
          total = number_to_token(total_num)
          dm2 = selected.map { |t| { t["dm2"] => number_to_token(t["metric"]) } }
        else
          avg = total_num / denominator
          total = total_num
          dm2 = selected.map { |t| { t["dm2"] => t["metric"] } }
      end

      { "dm1" => dm1, "total" => total, "t" => total_num, "avg" => avg, "dm2" => dm2 }
    end
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
    credit_value = event.credit.value
    event_currency_symbol = event.currency_symbol
    virtual_credit_value = event.virtual_credit.value
    onsite_topups = event.pokes.where(action: 'topup').as_json
    online_orders = Order.credit_dashboard(@current_event).as_json

    online_credit_topups_money = OrderItem.where(order: event.orders.completed, catalog_item: event.credit).sum(:amount) * credit_value
    online_virtual_topups_money = OrderItem.where(order: event.orders.completed, catalog_item: event.virtual_credit).sum(:amount) * virtual_credit_value
    onsite_topups_money = onsite_topups.map { |topup| topup['monetary_total_price'] }.sum
    topups = online_credit_topups_money + online_virtual_topups_money + onsite_topups_money
    sales = event.pokes.where(action: 'sale').includes(:station)
    online_refunds = event.refunds
    onsite_refunds = event.pokes.where(action: 'refund')
    refunds_money = (online_refunds.sum(:credit_base) * credit_value) + onsite_refunds.sum(:monetary_total_price)
    customers = event.customers
    purchasers = event.pokes.where(action: 'purchase')
    gtags_credits = event.gtags.where(active: true).map(&:credits).sum
    gtags_virtuals = event.gtags.where(active: true).map(&:virtual_credits).sum

    purchasers_by_payment_method_money = {}
    topups_by_payment_method_money = {}
    purchase_by_source = {}

    purchasers.select("payment_method, sum(monetary_total_price) as total").group(:payment_method).as_json.map { |purchase| purchase_by_source[purchase['source']] = purchase['monetary_total_price'].to_f }
    purchasers.select("payment_method, sum(monetary_total_price) as total").group(:payment_method).as_json.map { |purchase| purchasers_by_payment_method_money[purchase['payment_method']] = purchase['total'].to_f }
    onsite_topups.map { |topup| topups_by_payment_method_money[topup['payment_method']] = topup['money'] }

    data = {
      dashboard: {
        topups: {
          colors: ['#009688', '#66FF99'],
          icon: 'attach_money',
          title: { text: "Total Topups in #{event_currency_symbol}", number: number_to_reports(topups) },
          subtitle: [
            { text: 'Online', number: number_to_reports(online_credit_topups_money + online_virtual_topups_money) },
            { text: 'Onsite', number: number_to_reports(onsite_topups_money) }
          ]
        },
        sales: {
          colors: ['#FF4E50', '#F9D423'],
          icon: 'equalizer',
          title: { text: "Total Sales in #{event_currency_symbol}", number: number_to_reports(sales.sum(:credit_amount).to_f.abs) },
          subtitle: [
            { text: 'At Bars', number: number_to_reports(sales.where(stations: { category: 'bar' }).sum(:credit_amount).to_f.abs) },
            { text: 'At vendors', number: number_to_reports(sales.where(stations: { category: 'vendor' }).sum(:credit_amount).to_f.abs) }
          ]
        },
        products: {
          colors: ['#514A9D', '#24C6DC'],
          icon: 'add_shopping_cart',
          title: { text: 'Total Products Sold', number: sales.count },
          subtitle: [
            { text: 'At Bars', number: number_with_delimiter(sales.where(stations: { category: 'bar' }).count) },
            { text: 'At vendors', number: number_with_delimiter(sales.where(stations: { category: 'vendor' }).count) }
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
          title: { text: "Remaining Balance in #{event_currency_symbol}", number: number_to_reports(gtags_credits + gtags_virtuals) },
          subtitle: [
            { text: 'Standard', number: number_to_reports(gtags_credits) },
            { text: 'Virtual', number: number_to_reports(gtags_virtuals) }
          ]
        },
        customers: {
          colors: ['#355C7D', '#C06C84'],
          icon: 'supervisor_account',
          title: { text: 'Spending Customers', number: number_with_delimiter(sales.select(:customer_id).distinct.pluck(:customer_id).count) },
          subtitle: [
            { text: 'Average Spend per Customer', number: number_to_event_currency((sales.sum(:credit_amount).abs / sales.select(:customer_id).distinct.pluck(:customer_id).count) && 0) }
          ]
        }
      },
      key_metrics: {
        total_income: {
          colors: ['#1A2980', '#26D0CE'],
          icon: 'input',
          title: { text: 'Total Income', number: 0 },
          subtitle: { online: 0, onsite: 0, total: 0 }
        },
        total_sales: {
          colors: ['#FF4E50', '#F9D423'],
          icon: 'equalizer',
          title: { text: 'Total Sales', number: number_to_reports(sales.sum(:credit_amount).to_f.abs) },
          subtitle: { online: "-", onsite: number_to_reports(sales.sum(:credit_amount).to_f.abs), total: number_to_reports(sales.sum(:credit_amount).to_f.abs) }
        },
        total_refunds: {
          colors: ['#FF5050', '#F3A183'],
          icon: 'money_off',
          title: { text: 'Total Refunds', number: number_to_reports(refunds_money) },
          subtitle: { online: number_to_reports(online_refunds.sum(:credit_base) * credit_value), onsite: number_to_reports(onsite_refunds.sum(:monetary_total_price)), total: 0 }
        },
        outstanding: {
          colors: ['#001510', '#00bf8f'],
          icon: 'account_balance_wallet',
          title: { text: 'Outstanding', number: 0 },
          subtitle: { online: 0, onsite: 0, total: 0 }
        }
      }
    }

    data[key]
  end
end
