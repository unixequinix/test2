module CreditAnalytics
  extend ActiveSupport::Concern
  include BaseAnalytics

  # Onsite Topups
  #
  def credit_topups_base(grouping: :day, station_filter: [], credit_filter: [])
    topups_base(station_filter: station_filter, credit_filter: credit_filter).group_by_period(grouping, :date).sum(:credit_amount)
  end

  def credit_topups(grouping: :day, credit_filter: [], station_filter: [], operator_filter: [])
    topups(station_filter: station_filter, credit_filter: credit_filter, operator_filter: operator_filter).group_by_period(grouping, :date).sum(:credit_amount)
  end

  def credit_topups_base_total(credit_filter: [], station_filter: [])
    topups_base(station_filter: station_filter, credit_filter: credit_filter).sum(:credit_amount)
  end

  def credit_topups_total(credit_filter: [], station_filter: [], operator_filter: [])
    topups(station_filter: station_filter, credit_filter: credit_filter, operator_filter: operator_filter).sum(:credit_amount)
  end

  # Online orders
  #
  def credit_online_orders_income(grouping: :day, payment_filter: [], credit_filter: [], redeemed: [])
    if [credit_filter].flatten.map(&:class).include?(Token)
      online_order_items_tokens(order_filter: online_orders_income_tokens(payment_filter: payment_filter, redeemed: redeemed, credit_filter: credit_filter)).group_by_period(grouping, :created_at).sum(:amount)
    else
      sum = credit_filter.present? ? [credit_filter].flatten.map { |credit| credit.class.to_s.underscore.pluralize.to_s }.join("+") : "credits + virtual_credits"
      online_orders_income(payment_filter: payment_filter, redeemed: redeemed).group_by_period(grouping, :created_at).sum(sum)
    end
  end

  def credit_online_orders_outcome(grouping: :day, payment_filter: [], credit_filter: [], redeemed: [])
    if [credit_filter].flatten.map(&:class).include?(Token)
      online_order_items_tokens(order_filter: online_orders_outcome_tokens(payment_filter: payment_filter, redeemed: redeemed)).group_by_period(grouping, :created_at).sum(:amount)
    else
      sum = credit_filter.present? ? [credit_filter].flatten.map { |credit| credit.class.to_s.underscore.pluralize.to_s }.join("+") : "credits + virtual_credits"
      abs(online_orders_outcome(payment_filter: payment_filter, redeemed: redeemed).group_by_period(grouping, :created_at).sum(sum))
    end
  end

  def credit_online_orders(grouping: :day, payment_filter: [], credit_filter: [], redeemed: [])
    if [credit_filter].flatten.map(&:class).include?(Token)
      online_order_items_tokens(order_filter: online_orders_income_tokens(payment_filter: payment_filter, redeemed: redeemed)).group_by_period(grouping, :created_at).sum(:amount)
    else
      sum = credit_filter.present? ? [credit_filter].flatten.map { |credit| credit.class.to_s.underscore.pluralize.to_s }.join("+") : "credits + virtual_credits"
      online_orders(payment_filter: payment_filter, redeemed: redeemed).group_by_period(grouping, :created_at).sum(sum)
    end
  end

  def credit_online_orders_income_total(credit_filter: credits, payment_filter: [], redeemed: [])
    if [credit_filter].flatten.map(&:class).include?(Token)
      online_order_items_tokens(order_filter: online_orders_income_tokens(payment_filter: payment_filter, redeemed: redeemed, credit_filter: credit_filter)).sum(:amount)
    else
      sum = credit_filter.present? ? [credit_filter].flatten.map { |credit| credit.class.to_s.underscore.pluralize.to_s }.join("+") : "credits + virtual_credits"
      online_orders_income(payment_filter: payment_filter, redeemed: redeemed).sum(sum)
    end
  end

  def credit_online_orders_outcome_total(credit_filter: credits, payment_filter: [], redeemed: [])
    if [credit_filter].flatten.map(&:class).include?(Token)
      online_order_items_tokens(order_filter: online_orders_outcome_tokens(payment_filter: payment_filter, redeemed: redeemed, credit_filter: credit_filter)).sum(:amount)
    else
      sum = credit_filter.present? ? [credit_filter].flatten.map { |credit| credit.class.to_s.underscore.pluralize.to_s }.join("+") : "credits + virtual_credits"
      online_orders_outcome(payment_filter: payment_filter, redeemed: redeemed).sum(sum).abs
    end
  end

  def credit_online_orders_total(credit_filter: credits, payment_filter: [], redeemed: [])
    if [credit_filter].flatten.map(&:class).include?(Token)
      online_order_items_tokens(redeemed: redeemed, credit_filter: credit_filter).sum(:amount)
    else
      sum = credit_filter.present? ? [credit_filter].flatten.map { |credit| credit.class.to_s.underscore.pluralize.to_s }.join("+") : "credits + virtual_credits"
      online_orders(payment_filter: payment_filter, redeemed: redeemed).sum(sum)
    end
  end

  # Box Office
  #
  def credit_box_office(grouping: :day, credit_filter: [], station_filter: [], catalog_filter: [])
    box_office(credit_filter: credit_filter, station_filter: station_filter, catalog_filter: catalog_filter).group_by_period(grouping, :date).sum(:credit_amount)
  end

  def credit_box_office_total(credit_filter: [], station_filter: [], catalog_filter: [])
    box_office(credit_filter: credit_filter, station_filter: station_filter, catalog_filter: catalog_filter).sum(:credit_amount)
  end

  # Sales
  #
  def credit_sales(grouping: :day, credit_filter: [], station_filter: [], operator_filter: [])
    sales(station_filter: station_filter, credit_filter: credit_filter, operator_filter: operator_filter).group_by_period(grouping, :date).sum("credit_amount * -1")
  end

  def credit_sales_total(credit_filter: [], station_filter: [], operator_filter: [], customer_filter: [])
    sales(station_filter: station_filter, credit_filter: credit_filter, operator_filter: operator_filter, customer_filter: customer_filter).sum("credit_amount").abs
  end

  # Credentials
  #
  def credit_credential(grouping: :day, credit_filter: credits, credential_filter: [], catalog_filter: catalog_items.where(type: %w[Credit VirtualCredit Pack]))
    credential_filter = tickets + gtags if credential_filter.empty?
    credential_filter = credential_filter.flatten.map { |item| { item.class.to_s => item.id } }.flat_map(&:entries).group_by(&:first).map { |k, v| Hash[k, v.map(&:last)] }

    credentials = ticket_types.includes(:catalog_item).where(catalog_items: { id: catalog_filter }).map do |tt|
      sum = [credit_filter].flatten.map { |cred| tt.catalog_item.credits_for(cred) }.reject(&:zero?).sum
      credential_filter.map { |credential| credential.keys[0].constantize.where(id: credential.values, ticket_type: tt.id).group_by_period(grouping, :created_at).sum(sum) }.delete_if(&:empty?) unless sum.zero?
    end.compact.flatten

    credentials.inject { |h1, h2| merge(h1, h2) } || {}
  end

  def credit_credential_total(credit_filter: credits, items: [])
    total(credit_credential(grouping: :year, credit_filter: credit_filter, credential_filter: items))
  end

  # Online Refunds
  #
  def credit_online_refunds_fee(grouping: :day, credit_filter: [], payment_filter: [])
    online_refunds(payment_filter: payment_filter, credit_filter: credit_filter).group_by_period(grouping, :created_at).sum("ABS(credit_fee)")
  end

  def credit_online_refunds_base(grouping: :day, credit_filter: [], payment_filter: [])
    online_refunds(payment_filter: payment_filter, credit_filter: credit_filter).group_by_period(grouping, :created_at).sum("ABS(credit_base)")
  end

  def credit_online_refunds(grouping: :day, credit_filter: [], payment_filter: [])
    online_refunds(payment_filter: payment_filter, credit_filter: credit_filter).group_by_period(grouping, :created_at).sum("ABS(credit_base + credit_fee)")
  end

  def credit_online_refunds_fee_total(credit_filter: [], payment_filter: [])
    online_refunds(payment_filter: payment_filter, credit_filter: credit_filter).sum("credit_fee").abs
  end

  def credit_online_refunds_base_total(credit_filter: [], payment_filter: [])
    online_refunds(payment_filter: payment_filter, credit_filter: credit_filter).sum("credit_base").abs
  end

  def credit_online_refunds_total(credit_filter: [], payment_filter: [])
    online_refunds(payment_filter: payment_filter, credit_filter: credit_filter).sum("credit_base + credit_fee").abs
  end

  # Onsite Refunds
  #
  def credit_onsite_refunds_base(grouping: :day, credit_filter: [], station_filter: [])
    onsite_refunds_base(credit_filter: credit_filter, station_filter: station_filter).group_by_period(grouping, :date).sum("ABS(credit_amount)")
  end

  def credit_onsite_refunds(grouping: :day, credit_filter: [], station_filter: [])
    abs(onsite_refunds(credit_filter: credit_filter, station_filter: station_filter).group_by_period(grouping, :date).sum(:credit_amount))
  end

  def credit_onsite_refunds_base_total(credit_filter: [], station_filter: [])
    onsite_refunds_base(credit_filter: credit_filter, station_filter: station_filter).sum("ABS(credit_amount)")
  end

  def credit_onsite_refunds_total(credit_filter: [], station_filter: [])
    onsite_refunds(credit_filter: credit_filter, station_filter: station_filter).sum(:credit_amount).abs
  end

  # All Refunds
  #
  def credit_refunds(grouping: :day, credit_filter: credits)
    merge(credit_online_refunds(grouping: grouping, credit_filter: credit_filter), credit_onsite_refunds(grouping: grouping, credit_filter: credit_filter))
  end

  def credit_refunds_total(credit_filter: credits)
    credit_online_refunds_total(credit_filter: credit_filter) + credit_onsite_refunds_total(credit_filter: credit_filter)
  end

  # Topup Fees
  #
  def gtag_deposit_fee_pokes(credit_filter: [], station_filter: [], operator_filter: [])
    pokes.where(action: "fee", description: "gtag_deposit").with_station(station_filter).with_operator(operator_filter).with_credit(credit_filter).is_ok
  end

  def credit_gtag_deposit_fee(grouping: :day, credit_filter: [], station_filter: [], operator_filter: [])
    gtag_deposit_fee_pokes(credit_filter: credit_filter, station_filter: station_filter, operator_filter: operator_filter).group_by_period(grouping, :date).sum("ABS(credit_amount)")
  end

  def count_gtag_deposit_fee(grouping: :day, credit_filter: [], station_filter: [], operator_filter: [])
    gtag_deposit_fee_pokes(credit_filter: credit_filter, station_filter: station_filter, operator_filter: operator_filter).group_by_period(grouping, :date).count
  end

  def credit_gtag_deposit_fee_total(credit_filter: [], station_filter: [], operator_filter: [])
    gtag_deposit_fee_pokes(credit_filter: credit_filter, station_filter: station_filter, operator_filter: operator_filter).sum("ABS(credit_amount)")
  end

  def onsite_initial_topup_fee_pokes(credit_filter: [], station_filter: [], operator_filter: [])
    pokes.where(action: "fee", description: "initial").with_station(station_filter).with_operator(operator_filter).with_credit(credit_filter).is_ok
  end

  def credit_onsite_initial_topup_fee(grouping: :day, credit_filter: [], station_filter: [], operator_filter: [])
    onsite_initial_topup_fee_pokes(credit_filter: credit_filter, station_filter: station_filter, operator_filter: operator_filter).group_by_period(grouping, :date).sum("ABS(credit_amount)")
  end

  def count_onsite_initial_topup_fee(grouping: :day, credit_filter: [], station_filter: [], operator_filter: [])
    onsite_initial_topup_fee_pokes(credit_filter: credit_filter, station_filter: station_filter, operator_filter: operator_filter).group_by_period(grouping, :date).count
  end

  def credit_onsite_initial_topup_fee_total(credit_filter: [], station_filter: [], operator_filter: [])
    onsite_initial_topup_fee_pokes(credit_filter: credit_filter, station_filter: station_filter, operator_filter: operator_filter).sum("ABS(credit_amount)")
  end

  def every_onsite_topup_fee_pokes(credit_filter: [], station_filter: [], operator_filter: [])
    pokes.where(action: "fee", description: "topup").with_station(station_filter).with_operator(operator_filter).with_credit(credit_filter).is_ok
  end

  def credit_every_onsite_topup_fee(grouping: :day, credit_filter: [], station_filter: [], operator_filter: [])
    every_onsite_topup_fee_pokes(credit_filter: credit_filter, station_filter: station_filter, operator_filter: operator_filter).group_by_period(grouping, :date).sum("ABS(credit_amount)")
  end

  def count_every_onsite_topup_fee(grouping: :day, credit_filter: [], station_filter: [], operator_filter: [])
    every_onsite_topup_fee_pokes(credit_filter: credit_filter, station_filter: station_filter, operator_filter: operator_filter).group_by_period(grouping, :date).count
  end

  def credit_every_onsite_topup_fee_total(credit_filter: [], station_filter: [], operator_filter: [])
    every_onsite_topup_fee_pokes(credit_filter: credit_filter, station_filter: station_filter, operator_filter: operator_filter).sum("ABS(credit_amount)")
  end

  # Refund fees
  #
  def gtag_return_fee_pokes(credit_filter: [], station_filter: [], operator_filter: [])
    pokes.where(action: "fee", description: "gtag_return").with_station(station_filter).with_operator(operator_filter).with_credit(credit_filter).is_ok
  end

  def credit_gtag_return_fee(grouping: :day, credit_filter: [], station_filter: [], operator_filter: [])
    gtag_return_fee_pokes(credit_filter: credit_filter, station_filter: station_filter, operator_filter: operator_filter).group_by_period(grouping, :date).sum("ABS(credit_amount)")
  end

  def count_gtag_return_fee(grouping: :day, credit_filter: [], station_filter: [], operator_filter: [])
    gtag_return_fee_pokes(credit_filter: credit_filter, station_filter: station_filter, operator_filter: operator_filter).group_by_period(grouping, :date).count
  end

  def credit_gtag_return_fee_total(credit_filter: [], station_filter: [], operator_filter: [])
    gtag_return_fee_pokes(credit_filter: credit_filter, station_filter: station_filter, operator_filter: operator_filter).sum("ABS(credit_amount)")
  end

  def every_onsite_refund_fee_pokes(credit_filter: [], station_filter: [], operator_filter: [])
    pokes.where(action: "fee", description: "refund").with_station(station_filter).with_operator(operator_filter).with_credit(credit_filter).is_ok
  end

  def credit_every_onsite_refund_fee(grouping: :day, credit_filter: [], station_filter: [], operator_filter: [])
    every_onsite_refund_fee_pokes(credit_filter: credit_filter, station_filter: station_filter, operator_filter: operator_filter).group_by_period(grouping, :date).sum("ABS(credit_amount)")
  end

  def count_every_onsite_refund_fee(grouping: :day, credit_filter: [], station_filter: [], operator_filter: [])
    every_onsite_refund_fee_pokes(credit_filter: credit_filter, station_filter: station_filter, operator_filter: operator_filter).group_by_period(grouping, :date).count
  end

  def credit_every_onsite_refund_fee_total(credit_filter: [], station_filter: [], operator_filter: [])
    every_onsite_refund_fee_pokes(credit_filter: credit_filter, station_filter: station_filter, operator_filter: operator_filter).sum("ABS(credit_amount)")
  end

  # All Fees
  #
  def income_fees(credit_filter: [], station_filter: [], operator_filter: [])
    pokes.where(action: "fee", description: INCOME_FEES).with_station(station_filter).with_operator(operator_filter).with_credit(credit_filter).is_ok
  end

  def outcome_fees(credit_filter: [], station_filter: [], operator_filter: [])
    pokes.where(action: "fee", description: OUTCOME_FEES).with_station(station_filter).with_operator(operator_filter).with_credit(credit_filter).is_ok
  end

  def credit_income_fees(grouping: :day, credit_filter: [], station_filter: [], operator_filter: [])
    income_fees(credit_filter: credit_filter, station_filter: station_filter, operator_filter: operator_filter).group_by_period(grouping, :date).sum("ABS(credit_amount)")
  end

  def credit_outcome_fees(grouping: :day, credit_filter: [], station_filter: [], operator_filter: [])
    outcome_fees(credit_filter: credit_filter, station_filter: station_filter, operator_filter: operator_filter).group_by_period(grouping, :date).sum("ABS(credit_amount)")
  end

  def credit_fees(grouping: :day, credit_filter: [], station_filter: [], operator_filter: [])
    merge_subtract(credit_income_fees(grouping: grouping, credit_filter: credit_filter, station_filter: station_filter, operator_filter: operator_filter),
                   credit_outcome_fees(grouping: grouping, credit_filter: credit_filter, station_filter: station_filter, operator_filter: operator_filter))
  end

  def count_credit_income_fees(grouping: :day, credit_filter: [], station_filter: [], operator_filter: [])
    income_fees(credit_filter: credit_filter, station_filter: station_filter, operator_filter: operator_filter).group_by_period(grouping, :date).count
  end

  def count_credit_outcome_fees(grouping: :day, credit_filter: [], station_filter: [], operator_filter: [])
    outcome_fees(credit_filter: credit_filter, station_filter: station_filter, operator_filter: operator_filter).group_by_period(grouping, :date).count
  end

  def credit_income_fees_total(credit_filter: [], station_filter: [], operator_filter: [])
    income_fees(credit_filter: credit_filter, station_filter: station_filter, operator_filter: operator_filter).sum(:credit_amount).abs
  end

  def credit_outcome_fees_total(credit_filter: [], station_filter: [], operator_filter: [])
    outcome_fees(credit_filter: credit_filter, station_filter: station_filter, operator_filter: operator_filter).sum(:credit_amount).abs
  end

  def credit_fees_total(credit_filter: credits, station_filter: [], operator_filter: [])
    credit_income_fees_total(credit_filter: credit_filter, station_filter: station_filter, operator_filter: operator_filter) -
      credit_outcome_fees_total(credit_filter: credit_filter, station_filter: station_filter, operator_filter: operator_filter)
  end

  def single_fee(credit_filter: [], station_filter: [], operator_filter: [], fee_filter: [])
    pokes.where(action: "fee").with_description(fee_filter).with_station(station_filter).with_operator(operator_filter).with_credit(credit_filter).is_ok
  end

  def credit_single_fee(grouping: :day, credit_filter: [], station_filter: [], operator_filter: [], fee_filter: [])
    single_fee(credit_filter: credit_filter, station_filter: station_filter, operator_filter: operator_filter, fee_filter: fee_filter).group_by_period(grouping, :date).sum("ABS(credit_amount)")
  end

  def credit_single_fee_total(credit_filter: [], station_filter: [], operator_filter: [], fee_filter: [])
    single_fee(credit_filter: credit_filter, station_filter: station_filter, operator_filter: operator_filter, fee_filter: fee_filter).sum(:credit_amount).abs
  end

  def count_single_fee(grouping: :day, credit_filter: [], station_filter: [], operator_filter: [], fee_filter: [])
    single_fee(credit_filter: credit_filter, station_filter: station_filter, operator_filter: operator_filter, fee_filter: fee_filter).group_by_period(grouping, :date).count
  end

  # Income
  #
  def credit_income(grouping: :day, credit_filter: credits)
    merge(credit_topups(grouping: grouping, credit_filter: credit_filter), credit_income_fees(grouping: grouping, credit_filter: credit_filter), credit_credential(grouping: grouping, credit_filter: credit_filter), credit_box_office(grouping: grouping, credit_filter: credit_filter), credit_online_orders_income(grouping: grouping, credit_filter: credit_filter))
  end

  def token_income(grouping: :day, credit_filter: tokens)
    merge(credit_topups(grouping: grouping, credit_filter: credit_filter), credit_income_fees(grouping: grouping, credit_filter: credit_filter), credit_credential(grouping: grouping, credit_filter: credit_filter), credit_box_office(grouping: grouping, credit_filter: credit_filter), credit_online_orders_income(grouping: grouping, credit_filter: credit_filter))
  end

  def credit_income_total(credit_filter: credits)
    credit_topups_total(credit_filter: credit_filter) + credit_income_fees_total(credit_filter: credit_filter) + credit_credential_total(credit_filter: credit_filter) + credit_box_office_total(credit_filter: credit_filter) + credit_online_orders_income_total(credit_filter: credit_filter)
  end

  # Outcome
  #
  def credit_outcome(grouping: :day, credit_filter: credits)
    merge(credit_online_refunds(grouping: grouping, credit_filter: credit_filter), credit_outcome_fees(grouping: grouping, credit_filter: credit_filter), credit_online_orders_outcome(grouping: grouping, credit_filter: credit_filter), credit_topups_fee(grouping: grouping, credit_filter: credit_filter))
  end

  def credit_outcome_total(credit_filter: credits)
    credit_online_refunds_total(credit_filter: credit_filter) + credit_onsite_refunds_base_total(credit_filter: credit_filter) + credit_outcome_fees_total(credit_filter: credit_filter) + credit_online_orders_outcome_total(credit_filter: credit_filter)
  end

  # Outstanding
  #
  def credit_outstanding(grouping: :day, credit_filter: credits)
    merge_subtract(credit_income(grouping: grouping, credit_filter: credit_filter), merge(credit_outcome(grouping: grouping, credit_filter: credit_filter), credit_sales(grouping: grouping, credit_filter: credit_filter)))
  end

  def credit_outstanding_total(credit_filter: credits)
    credit_income_total(credit_filter: credit_filter) - (credit_outcome_total(credit_filter: credit_filter) + credit_sales_total(credit_filter: credit_filter))
  end

  # Customers
  #
  def spending_customers(operator_filter: [])
    customers.where(id: sales.select(:customer_id).distinct.pluck(:customer_id)).with_operator(operator_filter)
  end

  def count_spending_customers(operator_filter: [])
    spending_customers(operator_filter: operator_filter).count
  end

  def spending_customer_average
    credit_sales_total / (spending_customers.nonzero? || 1)
  end

  def avg_spend_per_customer(operator_filter: [])
    cust = spending_customers(operator_filter: operator_filter)
    return 0 if cust.count.zero?

    credit_sales_total(customer_filter: cust) / cust.count.to_f
  end
end
