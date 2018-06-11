module CreditAnalytics
  extend ActiveSupport::Concern
  include BaseAnalytics

  # Onsite Topups
  #
  def credit_topups_base(grouping: :day, station_filter: [], credit_filter: [])
    topups(station_filter: station_filter, credit_filter: credit_filter).group_by_period(grouping, :date).sum(:credit_amount)
  end

  def credit_topups_fee(grouping: :day, station_filter: stations.with_category(TOPUPS_STATIONS), credit_filter: credits, fee_filter: TOPUP_FEES)
    abs(topups_fee(station_filter: station_filter, credit_filter: credit_filter, fee_filter: fee_filter).group_by_period(grouping, :date).sum(:credit_amount))
  end

  def count_credit_topups_fees(grouping: :day, station_filter: stations.with_category(TOPUPS_STATIONS), credit_filter: credits, fee_filter: TOPUP_FEES)
    topups_fee(station_filter: station_filter, credit_filter: credit_filter, fee_filter: fee_filter).group_by_period(grouping, :date).count
  end

  def credit_topups(grouping: :day, credit_filter: [], station_filter: [])
    topups_base(station_filter: station_filter, credit_filter: credit_filter).group_by_period(grouping, :date).sum(:credit_amount)
  end

  def credit_topups_base_total(credit_filter: [], station_filter: [])
    topups(station_filter: station_filter, credit_filter: credit_filter).sum(:credit_amount)
  end

  def credit_topups_fee_total(station_filter: stations.with_category(TOPUPS_STATIONS), credit_filter: credits, fee_filter: TOPUP_FEES)
    topups_fee(station_filter: station_filter, credit_filter: credit_filter, fee_filter: fee_filter).sum(:credit_amount).abs
  end

  def credit_topups_total(credit_filter: [], station_filter: [])
    topups_base(station_filter: station_filter, credit_filter: credit_filter).sum(:credit_amount)
  end

  # Online orders
  #
  def credit_online_orders_income(grouping: :day, payment_filter: [], credit_filter: [], redeemed: [])
    sum = credit_filter.present? ? [credit_filter].flatten.map { |credit| credit.class.to_s.underscore.pluralize.to_s }.join("+") : "credits + virtual_credits"
    credit_income_online_orders(payment_filter: payment_filter, redeemed: redeemed).group_by_period(grouping, :created_at).sum(sum)
  end

  def credit_online_orders_outcome(grouping: :day, payment_filter: [], credit_filter: [], redeemed: [])
    sum = credit_filter.present? ? [credit_filter].flatten.map { |credit| credit.class.to_s.underscore.pluralize.to_s }.join("+") : "credits + virtual_credits"
    credit_outcome_online_orders(payment_filter: payment_filter, redeemed: redeemed).group_by_period(grouping, :created_at).sum(sum)
  end

  def credit_online_orders(grouping: :day, payment_filter: [], credit_filter: [], redeemed: [])
    sum = credit_filter.present? ? [credit_filter].flatten.map { |credit| credit.class.to_s.underscore.pluralize.to_s }.join("+") : "credits + virtual_credits"
    online_orders(payment_filter: payment_filter, redeemed: redeemed).group_by_period(grouping, :created_at).sum(sum)
  end

  def credit_online_orders_income_total(credit_filter: credits, payment_filter: [], redeemed: [])
    sum = credit_filter.present? ? [credit_filter].flatten.map { |credit| credit.class.to_s.underscore.pluralize.to_s }.join("+") : "credits + virtual_credits"
    credit_income_online_orders(payment_filter: payment_filter, redeemed: redeemed).sum(sum).abs
  end

  def credit_online_orders_outcome_total(credit_filter: credits, payment_filter: [], redeemed: [])
    sum = credit_filter.present? ? [credit_filter].flatten.map { |credit| credit.class.to_s.underscore.pluralize.to_s }.join("+") : "credits + virtual_credits"
    credit_outcome_online_orders(payment_filter: payment_filter, redeemed: redeemed).sum(sum)
  end

  def credit_online_orders_total(credit_filter: credits, payment_filter: [], redeemed: [])
    sum = credit_filter.present? ? [credit_filter].flatten.map { |credit| credit.class.to_s.underscore.pluralize.to_s }.join("+") : "credits + virtual_credits"
    online_orders(payment_filter: payment_filter, redeemed: redeemed).sum(sum)
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
    abs(sales(station_filter: station_filter, credit_filter: credit_filter, operator_filter: operator_filter).group_by_period(grouping, :date).sum("credit_amount"))
  end

  def credit_sales_total(credit_filter: [], station_filter: [], operator_filter: [])
    sales(station_filter: station_filter, credit_filter: credit_filter, operator_filter: operator_filter).sum("credit_amount").abs
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
  def credit_online_refunds_fee(grouping: :day, credit_filter: credits, payment_filter: [])
    online_refunds(credit_filter: credit_filter, payment_filter: payment_filter).group_by_period(grouping, :created_at).sum(:credit_fee)
  end

  def credit_online_refunds_base(grouping: :day, credit_filter: credits, payment_filter: [])
    online_refunds(credit_filter: credit_filter, payment_filter: payment_filter).group_by_period(grouping, :created_at).sum(:credit_base)
  end

  def credit_online_refunds(grouping: :day, credit_filter: credits, payment_filter: [])
    online_refunds(credit_filter: credit_filter, payment_filter: payment_filter).group_by_period(grouping, :created_at).sum("credit_base + credit_fee")
  end

  def credit_online_refunds_base_total(credit_filter: credits, payment_filter: [])
    online_refunds(credit_filter: credit_filter, payment_filter: payment_filter).sum(:credit_base)
  end

  def credit_online_refunds_fee_total(credit_filter: credits, payment_filter: [])
    online_refunds(credit_filter: credit_filter, payment_filter: payment_filter).sum(:credit_fee)
  end

  def credit_online_refunds_total(credit_filter: credits, payment_filter: [])
    online_refunds(credit_filter: credit_filter, payment_filter: payment_filter).sum("credit_base + credit_fee")
  end

  # Onsite Refunds
  #
  def credit_onsite_refunds_base(grouping: :day, credit_filter: [], station_filter: [])
    onsite_refunds_base(credit_filter: credit_filter, station_filter: station_filter).group_by_period(grouping, :date).sum("ABS(credit_amount)")
  end

  def credit_onsite_refunds_fee(grouping: :day, credit_filter: [], station_filter: [])
    onsite_refunds_fee(credit_filter: credit_filter, station_filter: station_filter).group_by_period(grouping, :date).sum("ABS(credit_amount)")
  end

  def credit_onsite_refunds(grouping: :day, credit_filter: [], station_filter: [])
    abs(onsite_refunds(credit_filter: credit_filter, station_filter: station_filter).group_by_period(grouping, :date).sum(:credit_amount))
  end

  def credit_onsite_refunds_base_total(credit_filter: [], station_filter: [])
    onsite_refunds_base(credit_filter: credit_filter, station_filter: station_filter).sum("ABS(credit_amount)")
  end

  def credit_onsite_refunds_fee_total(credit_filter: [], station_filter: [])
    onsite_refunds_fee(credit_filter: credit_filter, station_filter: station_filter).sum("ABS(credit_amount)")
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

  # Fees
  #
  def credit_income_fees(grouping: :day, credit_filter: credits, station_filter: stations.where(category: TOPUPS_STATIONS))
    credit_onsite_refunds_fee(grouping: grouping, credit_filter: credit_filter, station_filter: station_filter)
  end

  def credit_outcome_fees(grouping: :day, credit_filter: credits, station_filter: stations.where(category: TOPUPS_STATIONS))
    credit_topups_fee(grouping: grouping, credit_filter: credit_filter, station_filter: station_filter)
  end

  def credit_fees(grouping: :day, credit_filter: credits)
    merge_subtract(credit_income_fees(grouping: grouping, credit_filter: credit_filter), credit_outcome_fees(grouping: grouping, credit_filter: credit_filter))
  end

  def count_credit_income_fees(grouping: :day, credit_filter: credits, station_filter: stations.where(category: TOPUPS_STATIONS))
    count_credit_onsite_refunds(grouping: grouping, credit_filter: credit_filter, station_filter: station_filter)
  end

  def count_credit_outcome_fees(grouping: :day, credit_filter: credits, station_filter: stations.where(category: TOPUPS_STATIONS))
    count_topups(grouping: grouping, credit_filter: credit_filter, station_filter: station_filter)
  end

  def credit_income_fees_total(credit_filter: credits, station_filter: stations.where(category: TOPUPS_STATIONS))
    credit_onsite_refunds_fee_total(credit_filter: credit_filter, station_filter: station_filter)
  end

  def credit_outcome_fees_total(credit_filter: credits, station_filter: stations.where(category: TOPUPS_STATIONS))
    credit_topups_fee_total(credit_filter: credit_filter, station_filter: station_filter)
  end

  def credit_fees_total(credit_filter: credits)
    credit_income_fees_total(credit_filter: credit_filter) - credit_outcome_fees_total(credit_filter: credit_filter)
  end

  # Income
  #
  def credit_income(grouping: :day, credit_filter: credits)
    merge(credit_topups(grouping: grouping, credit_filter: credit_filter), credit_onsite_refunds_fee(grouping: grouping, credit_filter: credit_filter), credit_credential(grouping: grouping, credit_filter: credit_filter), credit_box_office(grouping: grouping, credit_filter: credit_filter), credit_online_orders_income(grouping: grouping, credit_filter: credit_filter))
  end

  def credit_income_total(credit_filter: credits)
    credit_topups_total(credit_filter: credit_filter) + credit_onsite_refunds_fee_total(credit_filter: credit_filter) + credit_credential_total(credit_filter: credit_filter) + credit_box_office_total(credit_filter: credit_filter) + credit_online_orders_income_total(credit_filter: credit_filter)
  end

  # Outcome
  #
  def credit_outcome(grouping: :day, credit_filter: credits)
    merge(credit_online_refunds_base(grouping: grouping, credit_filter: credit_filter), credit_onsite_refunds_base(grouping: grouping, credit_filter: credit_filter), credit_online_orders_outcome(grouping: grouping, credit_filter: credit_filter), credit_topups_fee(grouping: grouping, credit_filter: credit_filter))
  end

  def credit_outcome_total(credit_filter: credits)
    credit_online_refunds_base_total(credit_filter: credit_filter) + credit_onsite_refunds_base_total(credit_filter: credit_filter) + credit_online_orders_outcome_total(credit_filter: credit_filter) + credit_topups_fee_total(credit_filter: credit_filter)
  end

  # Outstanding
  #
  def credit_outstanding(grouping: :day, credit_filter: credits)
    merge_subtract(credit_income(grouping: grouping, credit_filter: credit_filter), merge(credit_outcome(grouping: grouping, credit_filter: credit_filter), credit_sales(grouping: grouping, credit_filter: credit_filter)))
  end

  def credit_outstanding_total(credit_filter: credits)
    credit_income_total(credit_filter: credit_filter) - (credit_outcome_total(credit_filter: credit_filter) + credit_sales_total(credit_filter: credit_filter))
  end

  # Onsite Leftover Balance
  #
  def credit_onsite_leftover_balance(grouping: :day, credit_filter: credits)
    onsite_leftover_balance(credit_filter: credit_filter).group_by_period(grouping, :date).sum(:credit_amount)
  end

  def credit_onsite_leftover_balance_total(credit_filter: credits)
    onsite_leftover_balance(credit_filter: credit_filter).sum(:credit_amount)
  end

  # Online Leftover Balance
  #
  def credit_online_leftover_balance(grouping: :day, credit_filter: credits)
    income = merge(credit_online_orders(grouping: grouping, credit_filter: credit_filter, redeemed: false), credit_credential(grouping: grouping, credit_filter: credit_filter, credential_filter: [tickets.unredeemed, gtags.unredeemed]))
    outcome = credit_onsite_refunds(grouping: grouping)

    merge_subtract(income, outcome)
  end

  def credit_online_leftover_balance_total(credit_filter: credits)
    total(credit_online_leftover_balance(grouping: :year, credit_filter: credit_filter))
  end

  # Leftover balance
  #
  def credit_leftover_balance(grouping: :day, credit_filter: credits)
    merge(credit_onsite_leftover_balance(grouping: grouping, credit_filter: credit_filter), credit_online_leftover_balance(grouping: grouping, credit_filter: credit_filter))
  end

  def leftover_balance_total(credit_filter: credits)
    credit_onsite_leftover_balance_total(credit_filter: credit_filter) + credit_online_leftover_balance_total(credit_filter: credit_filter)
  end
end
