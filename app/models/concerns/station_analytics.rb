module StationAnalytics
  extend ActiveSupport::Concern
  include BaseAnalytics

  SALE_DESCRIPTIONS = %w[other_amount product tip].freeze

  # Product Sales
  #
  def product_sales(product_filter: [], credit_filter: [], product_type_filter: SALE_DESCRIPTIONS)
    pokes.where(action: 'sale', description: product_type_filter).with_product(product_filter).with_credit(credit_filter).is_ok
  end

  def count_product_sales(grouping: :day, product_filter: [], credit_filter: [], product_type_filter: SALE_DESCRIPTIONS)
    ids = pokes.select("max(id) as id").where(action: "sale", description: product_type_filter).with_credit(credit_filter).with_product(product_filter).group(:operation_id, :product_id)
    pokes.where(id: ids).group_by_period(grouping, :date).sum(:sale_item_quantity)
  end

  def count_product_sales_total(product_filter: [], credit_filter: [], product_type_filter: SALE_DESCRIPTIONS)
    total(count_product_sales(grouping: :year, product_filter: product_filter, credit_filter: credit_filter, product_type_filter: product_type_filter))
  end

  # Money Sales
  #
  def money_product_sales(grouping: :day, product_filter: [], credit_filter: [], product_type_filter: SALE_DESCRIPTIONS)
    abs(product_sales(product_filter: product_filter, credit_filter: credit_filter, product_type_filter: product_type_filter).group_by_period(grouping, :date).sum("credit_amount * #{credit.value}"))
  end

  def money_product_sales_total(product_filter: [], credit_filter: [], product_type_filter: SALE_DESCRIPTIONS)
    product_sales(product_filter: product_filter, credit_filter: credit_filter, product_type_filter: product_type_filter).sum("credit_amount * #{event.credit.value}").abs
  end

  # Credit Sales
  #
  def credit_product_sales(grouping: :day, credit_filter: [], product_filter: [], product_type_filter: SALE_DESCRIPTIONS)
    abs(product_sales(product_filter: product_filter, credit_filter: credit_filter, product_type_filter: product_type_filter).group_by_period(grouping, :date).sum(:credit_amount))
  end

  def credit_product_sales_total(credit_filter: [], product_filter: [], product_type_filter: SALE_DESCRIPTIONS)
    product_sales(product_filter: product_filter, credit_filter: credit_filter, product_type_filter: product_type_filter).sum(:credit_amount).abs
  end

  # Random
  #
  def count_operators
    pokes.pluck(:operator_id).uniq.count
  end

  def count_devices
    pokes.pluck(:device_id).uniq.count
  end
end
