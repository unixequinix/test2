module BaseAnalytics
  TOPUPS_STATIONS = %w[top_up_refund cs_topup_refund hospitality_top_up].freeze
  SALES_STATIONS = %w[bar vendor].freeze
  TOPUP_FEES = %w[gtag_deposit initial topup].freeze
  BOX_OFFICE_STATIONS = %w[box_office].freeze
  PAYMENT_METHODS = %w[card cash emv].freeze

  # Onsite Topups
  #
  def topups_base(station_filter: [], credit_filter: [], operator_filter: [])
    pokes.where(action: "record_credit", description: "topup").with_station(station_filter).with_credit(credit_filter).with_operator(operator_filter).is_ok
  end

  def topups_fee(station_filter: stations.with_category(TOPUPS_STATIONS), credit_filter: credits, fee_filter: TOPUP_FEES, operator_filter: [])
    return pokes.none unless credit.in?([credit_filter].flatten)
    pokes.where(action: "fee", description: fee_filter, station: station_filter).with_operator(operator_filter).is_ok
  end

  def topups(station_filter: [], credit_filter: [], operator_filter: [])
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
  def online_orders(payment_filter: [], redeemed: [])
    redeemed = [true, false] if redeemed.blank?
    orders.where(id: OrderItem.where(order: orders.completed.with_gateway(payment_filter), redeemed: redeemed).select(:order_id).distinct.pluck(:order_id))
  end

  def count_online_orders(grouping: :day, payment_filter: [], redeemed: [], credit_filter: [])
    return online_orders(payment_filter: payment_filter, redeemed: redeemed).group_by_period(grouping, :created_at).count if credit_filter.empty?
    merge(*credit_filter.map { |credit| online_orders(payment_filter: payment_filter, redeemed: redeemed).where("#{credit.class.to_s.underscore.pluralize} > 0").group_by_period(grouping, :created_at).count })
  end

  def online_orders_income(payment_filter: [], redeemed: [])
    online_orders(payment_filter: payment_filter, redeemed: redeemed).where("credits > 0")
  end

  def count_online_orders_income(grouping: :day, payment_filter: [], redeemed: [])
    online_orders(payment_filter: payment_filter, redeemed: redeemed).where("credits > 0").group_by_period(grouping, :created_at).count
  end

  def online_orders_outcome(payment_filter: [], redeemed: [])
    online_orders(payment_filter: payment_filter, redeemed: redeemed).where("credits < 0")
  end

  def count_online_orders_outcome(grouping: :day, payment_filter: [], redeemed: [])
    online_orders(payment_filter: payment_filter, redeemed: redeemed).where("credits < 0").group_by_period(grouping, :created_at).count
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
  def sales(station_filter: [], credit_filter: [], operator_filter: [])
    pokes.where(action: 'sale').with_station(station_filter).with_credit(credit_filter).with_operator(operator_filter).is_ok
  end

  def count_sales(grouping: :day, station_filter: [], credit_filter: [], operator_filter: [])
    sales(station_filter: station_filter, credit_filter: credit_filter, operator_filter: operator_filter).group_by_period(grouping, :date).count
  end

  # Online Refunds
  #
  def online_refunds(credit_filter: credits, payment_filter: [])
    return refunds.none unless credit.in?(credit_filter)
    refunds.completed.with_gateway(payment_filter)
  end

  def count_online_refunds(grouping: :day, payment_filter: [])
    online_refunds(payment_filter: payment_filter).group_by_period(grouping, :created_at).count
  end

  # Onsite Refunds
  #
  def onsite_refunds_fee(credit_filter: [], station_filter: [])
    pokes.where(action: "fee", description: "gtag_return").with_station(station_filter).with_credit(credit_filter).is_ok
  end

  def onsite_refunds_base(credit_filter: [], station_filter: [])
    pokes.where(action: "record_credit", description: "refund").with_station(station_filter).with_credit(credit_filter).is_ok
  end

  def onsite_refunds(credit_filter: [], station_filter: [])
    pokes.where(action: %w[record_credit fee], description: %w[refund gtag_return]).with_station(station_filter).with_credit(credit_filter).is_ok
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

  # Onsite Leftover Balance
  #
  def onsite_leftover_balance(credit_filter: credits)
    pokes.where(credit: credit_filter).is_ok
  end

  # Random
  #
  def spending_customers
    sales.select(:customer_id).distinct.count
  end

  def spending_customer_average
    credit_sales_total / (spending_customers.nonzero? || 1)
  end

  def online_payment_methods
    (online_orders.select(:gateway).distinct.pluck(:gateway) + online_refunds.select(:gateway).distinct.pluck(:gateway)).uniq.compact
  end

  def onsite_payment_methods
    pokes.where.not(monetary_total_price: [0, nil]).select(:payment_method).distinct.pluck(:payment_method).uniq.compact
  end

  # Helpers
  #
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
