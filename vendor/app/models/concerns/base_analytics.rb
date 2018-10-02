module BaseAnalytics
  TOPUPS_STATIONS = %w[top_up_refund cs_topup_refund hospitality_top_up].freeze
  SALES_STATIONS = %w[bar vendor].freeze
  BOX_OFFICE_STATIONS = %w[box_office].freeze
  PAYMENT_METHODS = %w[card cash emv].freeze
  TOPUP_FEES = %w[gtag_deposit initial topup].freeze
  REFUND_FEES = %w[gtag_return refund].freeze
  INCOME_FEES = %w[gtag_return].freeze
  OUTCOME_FEES = %w[gtag_deposit initial topup refund].freeze

  # Onsite Topups
  #
  def topups(station_filter: [], credit_filter: [], operator_filter: [])
    pokes.where(action: "record_credit", description: "topup").with_station(station_filter).with_credit(credit_filter).with_operator(operator_filter).is_ok
  end

  def topups_base(station_filter: [], credit_filter: [], operator_filter: [])
    pokes.where(action: %w[record_credit fee], description: TOPUP_FEES).with_station(station_filter).with_credit(credit_filter).with_operator(operator_filter).is_ok
  end

  def monetary_topups(station_filter: [], payment_filter: [], operator_filter: [])
    pokes.where(action: "topup").with_station(station_filter).with_payment(payment_filter).with_operator(operator_filter).is_ok
  end

  def count_topups(grouping: :day, station_filter: [], credit_filter: [], operator_filter: [])
    topups(station_filter: station_filter, credit_filter: credit_filter, operator_filter: operator_filter).group_by_period(grouping, :date).count
  end

  # Online orders
  #
  def online_order_items_tokens(payment_filter: [], redeemed: [], credit_filter: [], order_filter: orders)
    redeemed = [true, false] if redeemed.blank?
    OrderItem.with_catalog_item(catalog_items_tokens(catalog_item_filter: credit_filter)).where(order: order_filter.completed.with_gateway(payment_filter), redeemed: redeemed)
  end

  def online_orders_tokens(payment_filter: [], redeemed: [], credit_filter: tokens)
    orders.where(id: online_order_items_tokens(payment_filter: payment_filter, redeemed: redeemed, credit_filter: credit_filter).distinct.pluck(:order_id))
  end

  def online_orders(payment_filter: [], redeemed: [], catalog_item_filter: [])
    redeemed = [true, false] if redeemed.blank?
    ids = OrderItem.with_catalog_item(catalog_item_filter).where(order: orders, redeemed: redeemed).select(:order_id).distinct.pluck(:order_id)
    orders.where(id: ids).completed.with_gateway(payment_filter)
  end

  def count_online_orders(grouping: :day, payment_filter: [], redeemed: [], credit_filter: [], catalog_item_filter: [])
    return online_orders(payment_filter: payment_filter, redeemed: redeemed).group_by_period(grouping, :created_at).count if credit_filter.empty?

    if [catalog_item_filter].flatten.empty?
      merge(*credit_filter.map { |credit| online_orders(payment_filter: payment_filter, redeemed: redeemed).where("#{credit.class.to_s.underscore.pluralize} > 0").group_by_period(grouping, :created_at).count })
    else
      online_orders(payment_filter: payment_filter, redeemed: redeemed, catalog_item_filter: catalog_item_filter).group_by_period(grouping, :created_at).count
    end
  end

  def count_online_orders_tokens(grouping: :day, payment_filter: [], redeemed: [], credit_filter: tokens, catalog_item_filter: tokens)
    return online_orders(payment_filter: payment_filter, redeemed: redeemed).group_by_period(grouping, :created_at).count if credit_filter.empty?

    if [catalog_item_filter].flatten.empty?
      merge(*credit_filter.map { |_token| online_orders_tokens(payment_filter: payment_filter, redeemed: redeemed, credit_filter: catalog_item_filter).group_by_period(grouping, :created_at).count })
    else
      online_orders_tokens(payment_filter: payment_filter, redeemed: redeemed, credit_filter: credit_filter).group_by_period(grouping, :created_at).count
    end
  end

  def online_orders_income(payment_filter: [], redeemed: [])
    online_orders(payment_filter: payment_filter, redeemed: redeemed).where("credits > 0 OR virtual_credits > 0")
  end

  def online_orders_income_tokens(payment_filter: [], redeemed: [], credit_filter: tokens)
    orders.where(id: online_order_items_tokens(payment_filter: payment_filter, redeemed: redeemed, credit_filter: credit_filter).reject { |oi| oi.amount.negative? }.pluck(:order_id))
  end

  def count_online_orders_income(grouping: :day, payment_filter: [], redeemed: [])
    online_orders(payment_filter: payment_filter, redeemed: redeemed).where("credits > 0 OR virtual_credits > 0").group_by_period(grouping, :created_at).count
  end

  def count_online_orders_income_tokens(grouping: :day, payment_filter: [], redeemed: [], credit_filter: tokens)
    online_orders_income_tokens(payment_filter: payment_filter, redeemed: redeemed, credit_filter: credit_filter).group_by_period(grouping, :created_at).count
  end

  def online_orders_outcome(payment_filter: [], redeemed: [])
    online_orders(payment_filter: payment_filter, redeemed: redeemed).where("credits < 0 OR virtual_credits < 0")
  end

  def online_orders_outcome_tokens(payment_filter: [], redeemed: [], credit_filter: tokens)
    orders.where(id: online_order_items_tokens(payment_filter: payment_filter, redeemed: redeemed, credit_filter: credit_filter).reject { |oi| oi.amount.positive? }.pluck(:order_id))
  end

  def count_online_orders_outcome(grouping: :day, payment_filter: [], redeemed: [])
    online_orders(payment_filter: payment_filter, redeemed: redeemed).where("credits < 0 OR virtual_credits < 0").group_by_period(grouping, :created_at).count
  end

  def count_online_orders_outcome_tokens(grouping: :day, payment_filter: [], redeemed: [], credit_filter: tokens)
    online_orders_outcome_tokens(payment_filter: payment_filter, redeemed: redeemed, credit_filter: credit_filter).group_by_period(grouping, :created_at).count
  end

  # Box Office
  #
  def box_office(credit_filter: [], station_filter: [], catalog_filter: [])
    pokes.where(action: "record_credit", description: "purchase").with_credit(credit_filter).with_station(station_filter).with_catalog_item(catalog_filter).is_ok
  end

  def count_box_office(grouping: :day, credit_filter: [], station_filter: [], catalog_filter: [])
    box_office(credit_filter: credit_filter, station_filter: station_filter, catalog_filter: catalog_filter).group_by_period(grouping, :date).count
  end

  def monetary_box_office(station_filter: [], payment_filter: [], catalog_filter: [])
    pokes.where(action: "purchase").with_station(station_filter).with_payment(payment_filter).with_catalog_item(catalog_filter).is_ok
  end

  # Sales
  #
  def sales(station_filter: [], credit_filter: [], operator_filter: [], customer_filter: [])
    pokes.where(action: 'sale').with_station(station_filter).with_credit(credit_filter).with_operator(operator_filter).with_customer(customer_filter).is_ok
  end

  def count_sales(grouping: :day, station_filter: [], credit_filter: [], operator_filter: [])
    sales(station_filter: station_filter, credit_filter: credit_filter, operator_filter: operator_filter).group_by_period(grouping, :date).count
  end

  # Online Refunds
  #
  def online_refunds(credit_filter: [], payment_filter: [])
    credit_filter = credits if credit_filter.blank?
    return refunds.none unless credit.in?([credit_filter].flatten)

    refunds.completed.with_gateway(payment_filter)
  end

  def count_online_refunds(grouping: :day, payment_filter: [], credit_filter: [])
    credit_filter = credits if credit_filter.blank?
    return {} unless credit.in?([credit_filter].flatten)

    online_refunds(payment_filter: payment_filter).group_by_period(grouping, :created_at).count
  end

  # Onsite Refunds
  #
  def onsite_refunds_base(credit_filter: [], station_filter: [])
    pokes.where(action: "record_credit", description: "refund").with_station(station_filter).with_credit(credit_filter).is_ok
  end

  def onsite_refunds(credit_filter: [], station_filter: [])
    pokes.where(action: %w[record_credit fee], description: REFUND_FEES).with_station(station_filter).with_credit(credit_filter).is_ok
  end

  def count_credit_onsite_refunds(grouping: :day, station_filter: [], credit_filter: [])
    onsite_refunds(credit_filter: credit_filter, station_filter: station_filter).group_by_period(grouping, :date).count
  end

  def monetary_onsite_refunds(station_filter: [], payment_filter: [])
    pokes.where(action: "refund").with_station(station_filter).with_payment(payment_filter).is_ok
  end

  def count_money_onsite_refunds(grouping: :day, station_filter: [], payment_filter: [])
    monetary_onsite_refunds(station_filter: station_filter, payment_filter: payment_filter).group_by_period(grouping, :date).count
  end

  # All Refunds
  #
  def count_all_refunds(grouping: :day)
    merge(count_money_onsite_refunds(grouping: grouping), count_online_refunds(grouping: grouping))
  end

  # Customers
  #
  def percentage_registered_customers(operator_filter: [])
    ((customers.registered.with_operator(operator_filter).count.to_f / customers.with_operator(operator_filter).count.to_f) * 100).round(2)
  end

  def avg_spend_per_customer(operator_filter: [])
    credit_sales_total / spending_customers(operator_filter: operator_filter)
  end

  # Random
  #
  def online_payment_methods(source = %i[topups refunds])
    source = [source].flatten
    result = []
    result += online_orders.select(:gateway).distinct.pluck(:gateway) if :topups.in?(source)
    result += online_orders_tokens.select(:gateway).distinct.pluck(:gateway) if :topups.in?(source)
    result += online_refunds.select(:gateway).distinct.pluck(:gateway) if :refunds.in?(source)
    result.uniq.compact
  end

  def onsite_payment_methods
    pokes.where.not(monetary_total_price: [0, nil]).select(:payment_method).distinct.pluck(:payment_method).uniq.compact
  end

  # Helpers
  #
  def catalog_items_tokens(catalog_item_filter: tokens)
    ([catalog_item_filter] + packs.where(id: PackCatalogItem.where(catalog_item_id: [catalog_item_filter].flatten.pluck(:id)).pluck(:pack_id))).flatten
  end

  def total(hash)
    hash.to_h.values.sum.to_f
  end

  def abs(hash)
    hash.map { |k, v| [k, v.to_f.abs] }.to_h
  end

  def merge(*metrics)
    metrics.inject { |metric1, metric2| metric1.merge(metric2) { |_, a, b| a + b } }
  end

  def merge_subtract(*metrics)
    metrics.inject { |metric1, metric2| metric1.merge(metric2) { |_, a, b| a - b } }
  end

  def plot(metrics)
    series = metrics.keys

    metrics.values.map(&:keys).flatten.uniq.sort.map do |date|
      result1 = { date_time: date.to_formatted_s(:human), date_time_sort: date.to_formatted_s(:db) }
      result2 = series.map { |serie| [serie, metrics[serie][date].to_f] }.to_h
      result1.merge(result2)
    end
  end
end
