module StationAnalytics
  extend ActiveSupport::Concern
  include BaseAnalytics

  SALE_DESCRIPTIONS = %w[other_amount product tip].freeze

  # POS
  #
  def pos_sales(product_filter: [], credit_filter: [], product_type_filter: SALE_DESCRIPTIONS)
    pokes.where(action: 'sale', description: product_type_filter).with_product(product_filter).with_credit(credit_filter).is_ok
  end

  def count_pos_sales(grouping: :day, product_filter: [], credit_filter: [], product_type_filter: SALE_DESCRIPTIONS)
    ids = pokes.select("max(id) as id").where(action: "sale", description: product_type_filter).with_credit(credit_filter).with_product(product_filter).group(:operation_id, :product_id)
    pokes.where(id: ids).group_by_period(grouping, :date).sum(:sale_item_quantity)
  end

  def count_pos_sales_total(product_filter: [], credit_filter: [], product_type_filter: SALE_DESCRIPTIONS)
    total(count_pos_sales(grouping: :year, product_filter: product_filter, credit_filter: credit_filter, product_type_filter: product_type_filter))
  end

  # Money POS
  #
  def money_pos_sales(grouping: :day, product_filter: [], credit_filter: [], product_type_filter: SALE_DESCRIPTIONS)
    abs(pos_sales(product_filter: product_filter, credit_filter: credit_filter, product_type_filter: product_type_filter).group_by_period(grouping, :date).sum("credit_amount * #{credit.value}"))
  end

  def money_pos_sales_total(product_filter: [], credit_filter: [], product_type_filter: SALE_DESCRIPTIONS)
    pos_sales(product_filter: product_filter, credit_filter: credit_filter, product_type_filter: product_type_filter).sum("credit_amount * #{event.credit.value}").abs
  end

  # Credit POS
  #
  def credit_pos_sales(grouping: :day, credit_filter: [], product_filter: [], product_type_filter: SALE_DESCRIPTIONS)
    pos_sales(product_filter: product_filter, credit_filter: credit_filter, product_type_filter: product_type_filter).group_by_period(grouping, :date).sum("credit_amount * -1")
  end

  def credit_pos_sales_total(credit_filter: [], product_filter: [], product_type_filter: SALE_DESCRIPTIONS)
    pos_sales(product_filter: product_filter, credit_filter: credit_filter, product_type_filter: product_type_filter).sum(:credit_amount).abs
  end

  # Checkin
  #
  def checkins(ticket_type_filter: [], operator_filter: [], credential_type_filter: [], catalog_item_filter: [])
    pokes.where(action: "checkin").with_ticket_type(ticket_type_filter).with_operator(operator_filter).with_catalog_item(catalog_item_filter).with_description(credential_type_filter).is_ok
  end

  def count_checkins(grouping: :day, ticket_type_filter: [], operator_filter: [], credential_type_filter: [], catalog_item_filter: [])
    checkins(ticket_type_filter: ticket_type_filter, operator_filter: operator_filter, credential_type_filter: credential_type_filter, catalog_item_filter: catalog_item_filter).group_by_period(grouping, :date).count
  end

  def checkins_total(ticket_type_filter: [], operator_filter: [], credential_type_filter: [], catalog_item_filter: [])
    checkins(ticket_type_filter: ticket_type_filter, operator_filter: operator_filter, credential_type_filter: credential_type_filter, catalog_item_filter: catalog_item_filter).count
  end

  # Checkpoints
  #
  def checkpoints(operator_filter: [], catalog_item_filter: [], direction_filter: [], staff_filter: [])
    pokes.where(action: "checkpoint").with_catalog_item(catalog_item_filter).with_operator(operator_filter).with_direction(direction_filter).with_staff(staff_filter).is_ok
  end

  def count_checkpoints(grouping: :day, operator_filter: [], catalog_item_filter: [], direction_filter: [], staff_filter: [])
    checkpoints(operator_filter: operator_filter, catalog_item_filter: catalog_item_filter, direction_filter: direction_filter, staff_filter: staff_filter).group_by_period(grouping, :date).count
  end

  def checkpoints_total(operator_filter: [], catalog_item_filter: [], direction_filter: [], staff_filter: [])
    checkpoints(operator_filter: operator_filter, catalog_item_filter: catalog_item_filter, direction_filter: direction_filter, staff_filter: staff_filter).count
  end

  # Exhibitor notes
  #
  def engagement(priority_filter: [])
    pokes.where(action: "exhibitor_note").with_priority(priority_filter).is_ok
  end

  def count_engagement(grouping: :day, priority_filter: [])
    engagement(priority_filter: priority_filter).group_by_period(grouping, :date).count
  end

  def unique_engagement(grouping: :day, priority_filter: [])
    engagement(priority_filter: priority_filter).select(:date, :customer_id).distinct(:customer_id).group_by_period(grouping, :date).count(:customer_id)
  end

  def average_engagement(grouping: :day, priority_filter: [])
    engagement(priority_filter: priority_filter).group_by_period(grouping, :date).average(:priority)
  end

  def engagement_total(priority_filter: [])
    engagement(priority_filter: priority_filter).count
  end

  # Random
  #
  def operators
    event.customers.where(id: pokes.select(:operator_id).distinct.pluck(:operator_id))
  end

  def count_operators
    pokes.pluck(:operator_id).uniq.count
  end

  def count_devices
    pokes.pluck(:device_id).uniq.count
  end
end
