class Poke < ApplicationRecord
  include Reportable

  belongs_to :event
  belongs_to :operation, class_name: "Transaction", optional: true, inverse_of: :pokes
  belongs_to :device, optional: true
  belongs_to :station, optional: true
  belongs_to :operator, class_name: "Customer", optional: true, inverse_of: :pokes_as_operator
  belongs_to :operator_gtag, class_name: "Gtag", optional: true, inverse_of: :pokes_as_operator
  belongs_to :customer, optional: true
  belongs_to :customer_gtag, class_name: "Gtag", optional: true, inverse_of: :pokes
  belongs_to :ticket_type, optional: true
  belongs_to :product, optional: true
  belongs_to :catalog_item, optional: true
  belongs_to :order, optional: true
  belongs_to :ticket, optional: true
  belongs_to :credit, polymorphic: true, optional: true

  scope :topups, -> { where(action: "topup") }
  scope :purchases, -> { where(action: "purchase") }
  scope :refunds, -> { where(action: "refund") }
  scope :sales, -> { where(action: "sale") }
  scope :not_cash_recon, -> { where.not(action: "cash_recon") }
  scope :exhibitor_note, -> { where(action: "exhibitor_note") }
  scope :record_credit, -> { where(action: "record_credit") }
  scope :not_record_credit, -> { where.not(description: "record_credit") }
  scope :credit_ops, -> { where(action: %w[record_credit sale]) }
  scope :fees, -> { where(action: 'fee') }
  scope :initial_fees, -> { where(description: "initial") }
  scope :topup_fees, -> { where(description: "topup") }
  scope :deposit_fees, -> { where(description: "gtag_deposit") }
  scope :return_fees, -> { where(description: "gtag_return") }
  scope :online_orders, -> { where(action: "record_credit", description: %w[record_credit order_applied_onsite]) }
  scope :has_money, -> { where.not(monetary_total_price: nil) }
  scope :has_credits, -> { where.not(credit_amount: nil) }
  scope :is_ok, -> { where(status_code: 0, error_code: nil) }
  scope :onsite, -> { where(source: "onsite") }
  scope :online, -> { where(source: "online") }
  scope :with_credit, ->(credits) { credits.present? ? where(credit: credits) : all }
  scope :with_payment, ->(payments) { payments.present? ? where(payment_method: payments) : all }
  scope :with_station, ->(stations) { stations.present? ? where(station: stations) : all }
  scope :with_catalog_item, ->(items) { items.present? ? where(catalog_item: items) : all }
  scope :with_operator, ->(operators) { operators.present? ? where(operator: operators) : all }
  scope :with_product, ->(products) { products.present? ? where(product: products) : all }
  scope :with_device, ->(devices) { devices.present? ? where(device: devices) : all }

  # Money
  #
  scope :money_recon_simple, lambda {
    select("CASE WHEN action = 'topup' THEN 'income' ELSE action END as action, action as description", "min(date) as date", :source, :payment_method, dimensions_customers, dimensions_operators_devices_simple, date_time_poke, dimensions_station, sum_money, count_operations)
      .joins(:station, :device, :operator, :operator_gtag)
      .has_money.is_ok.not_cash_recon
      .group(:action, :description, :source, :payment_method, grouping_customers, grouping_operators_devices, grouping_station, "date_time")
      .having("sum(monetary_total_price) !=0")
  }

  scope :money_recon, lambda {
    select("CASE WHEN action = 'topup' THEN 'income' ELSE action END as action, action as description", "min(date) as date", :source, :payment_method, date_time_poke, dimensions_customers, dimensions_operators_devices, dimensions_station, sum_money, count_operations)
      .joins(:station, :device, :customer, :customer_gtag, :operator, :operator_gtag)
      .has_money.is_ok.not_cash_recon
      .group(:action, :description, :source, :payment_method, grouping_customers, grouping_operators_devices, grouping_station, "date_time")
      .having("sum(monetary_total_price) !=0")
  }

  # Credits
  #

  scope :credit_flow_simple, lambda {
    select('min(date) as date', balance, detail, :credit_name, date_time_poke, dimensions_operators_devices_simple, dimensions_station, "sum(credit_amount) as credit_amount, credit_name as payment_method", countd_operations)
      .joins(:station, :device, :operator, :operator_gtag)
      .where.not(credit_amount: nil).has_credits.is_ok
      .group(:action, :description, :credit_name, grouping_operators_devices, grouping_station, "date_time")
      .having("sum(credit_amount) != 0")
  }

  scope :credit_flow, lambda {
    select('min(date) as date', balance, detail, :credit_name, date_time_poke, dimensions_customers, dimensions_operators_devices, dimensions_station, "sum(credit_amount) as credit_amount, credit_name as payment_method", countd_operations)
      .joins(:station, :device, :customer, :customer_gtag, :operator, :operator_gtag)
      .where.not(credit_amount: nil).has_credits.is_ok
      .group(:action, :description, :credit_name, grouping_customers, grouping_operators_devices, grouping_station, "date_time")
      .having("sum(credit_amount) != 0")
  }

  # Sales
  #

  scope :products_sale_simple, lambda {
    select('min(date) as date', :action, :description, :credit_name, dimensions_operators_devices_simple, date_time_poke, dimensions_station, is_alcohol, product_name, "sum(credit_amount)*-1 as credit_amount, credit_name as payment_method")
      .joins(:station, :device, :operator, :operator_gtag).left_outer_joins(:product)
      .sales.has_credits.is_ok
      .group(:action, :description, :credit_name, grouping_operators_devices, grouping_station, "date_time, is_alcohol, product_name")
  }

  scope :products_sale, lambda {
    select('min(date) as date', :action, :description, :credit_name, date_time_poke, dimensions_customers, dimensions_operators_devices, dimensions_station, is_alcohol, product_name, "sum(credit_amount)*-1 as credit_amount, credit_name as payment_method", count_operations, product_quantity)
      .joins(:station, :device, :customer, :customer_gtag, :operator, :operator_gtag).left_outer_joins(:product)
      .sales.has_credits.is_ok
      .group(:action, :description, :credit_name, grouping_customers, grouping_operators_devices, grouping_station, "date_time, is_alcohol, product_name")
  }

  scope :products_sale_stock, lambda {
    select('min(date) as date', :operation_id, :description, :sale_item_quantity, "gtags.tag_uid as operator_uid, CONCAT(customers.first_name, ' ', customers.last_name) as operator_name, devices.asset_tracker as device_name", dimensions_station, date_time_poke, product_name)
      .joins(:station, :device, :operator, :operator_gtag).left_outer_joins(:product)
      .sales.is_ok
      .group(:operation_id, :description, :sale_item_quantity, grouping_operators_devices, grouping_station, "date_time, product_name")
  }

  scope :top_products, lambda { |limit = 10|
    select('min(date) as date', product_name, "row_number() OVER (ORDER BY  sum(credit_amount) ) as sorter, sum(credit_amount)*-1 as credits")
      .joins(:product)
      .sales.is_ok
      .group("product_name")
      .order("credits desc")
      .limit(limit)
  }

  scope :top_items, lambda { |limit = 10|
    select("catalog_items.name as product_name, row_number() OVER (ORDER BY  sum(monetary_total_price) ) as sorter, sum(monetary_total_price) as credits")
      .joins(:catalog_item)
      .purchases.is_ok
      .group("product_name")
      .order("credits desc")
      .limit(limit)
  }

  scope :top_money_topup_amounts, lambda { |limit = 10|
    select("monetary_total_price as product_name, row_number() OVER (ORDER BY sum(monetary_total_price) ) as sorter, sum(monetary_total_price) as credits")
      .topups.is_ok
      .group("monetary_total_price")
      .order("credits desc")
      .limit(limit)
  }

  scope :top_credit_topup_amounts, lambda { |limit = 10|
    select("credit_amount as product_name, row_number() OVER (ORDER BY sum(credit_amount) ) as sorter, sum(credit_amount) as credits")
      .topups.is_ok
      .group("credit_amount")
      .order("credits desc")
      .limit(limit)
  }

  scope :top_stations, lambda { |category, credits = event.credits, limit = 10|
    select("stations.name as station_name, row_number() OVER (ORDER BY  sum(credit_amount) ) as sorter, sum(credit_amount)*-1 as credits")
      .joins(:station)
      .where(stations: { category: category }, credit: credits)
      .sales.is_ok
      .group("name")
      .order("credits desc")
      .limit(limit)
  }

  # Checkin
  #

  scope :checkin_ticket_type, lambda {
    select('min(date) as date', :action, :description, :ticket_type_id, dimensions_customers, dimensions_operators_devices, dimensions_station, date_time_poke, "devices.asset_tracker as device_name, catalog_items.name as catalog_item_name, COALESCE(ticket_types.name,catalog_items.name) as ticket_type_name, count(pokes.id) as total_tickets")
      .joins(:station, :device, :catalog_item, :customer, :customer_gtag, :operator, :operator_gtag).left_outer_joins(:ticket_type)
      .where(action: %w[checkin purchase]).is_ok
      .group(:action, :description, :ticket_type_id, grouping_customers, grouping_operators_devices, grouping_station, "date_time, device_name, catalog_item_name, ticket_type_name")
  }

  scope :validation_ticket_type, lambda {
    select('min(date) as date', :action, :description, :ticket_type_id, dimensions_operators_devices_simple, dimensions_station, date_time_poke, "customers.id as customer_id, CONCAT(customers.first_name, ' ', customers.last_name) as customer_name, devices.asset_tracker as device_name, catalog_items.name as catalog_item_name, COALESCE(ticket_types.name,catalog_items.name) as ticket_type_name, count(pokes.id) as total_tickets")
      .joins(:station, :device, :catalog_item, :customer, :operator, :operator_gtag).left_outer_joins(:ticket_type)
      .where(action: %w[ticket_validation]).is_ok
      .group(:action, :description, :ticket_type_id, "customers.id, customer_name", grouping_operators_devices, grouping_station, "date_time, device_name, catalog_item_name, ticket_type_name")
  }

  # Access
  #

  scope :access_in_out, lambda { |access|
    select('min(date) as date', date_time_poke, "CASE access_direction WHEN 1 THEN 'IN' WHEN -1 THEN 'OUT' END as direction, sum(access_direction) as access_direction")
      .joins(:customer)
      .where(catalog_item_id: access.id).where.not(access_direction: nil).is_ok.where('customers.operator = false')
      .group(:access_direction, "date_time")
  }

  scope :access_capacity, lambda { |access|
    select('min(date) as date', date_time_poke, access_capacity_query)
      .joins(:customer)
      .where(catalog_item_id: access.id).where.not(access_direction: nil).is_ok.where('customers.operator = false')
      .group(:access_direction, "date_time")
  }

  scope :access, lambda {
    select('min(date) as date', date_time_poke, sonar_access_patch, access_capacity_all_query)
      .joins(:station, :catalog_item, :customer)
      .where.not(access_direction: nil).is_ok.where('customers.operator = false')
      .group("date_time, zone, direction, access_direction")
  }

  # Engagement
  #

  scope :engagement, lambda {
    select('min(date) as date', :message, date_time_poke, dimensions_customers, dimensions_operators_devices, dimensions_station, count_operations, "AVG(priority) as priority")
      .joins(:station, :device, :customer, :customer_gtag, :operator, :operator_gtag)
      .exhibitor_note.is_ok
      .group(:message, grouping_customers, grouping_operators_devices, grouping_station, "date_time")
  }

  has_paper_trail on: %i[update destroy]

  def self.sonar_access_patch
    result = "CASE WHEN catalog_items.id = 3984 THEN 'Noche Sábado' WHEN catalog_items.id = 3983 THEN 'Noche Viernes' ELSE catalog_items.name END as zone" unless Rails.env.production?
    result = "CASE WHEN catalog_items.id = 9552 THEN 'Noche Sábado' WHEN catalog_items.id = 9553 THEN 'Noche Viernes' ELSE catalog_items.name END as zone" if Rails.env.production?
    result
  end

  def self.sonar_access_patch_capacity
    result = "CASE WHEN catalog_items.id = 3984 THEN 'Noche Sábado' WHEN catalog_items.id = 3983 THEN 'Noche Viernes' ELSE catalog_items.name END" unless Rails.env.production?
    result = "CASE WHEN catalog_items.id = 9552 THEN 'Noche Sábado' WHEN catalog_items.id = 9553 THEN 'Noche Viernes' ELSE catalog_items.name END" if Rails.env.production?
    result
  end

  def self.date_time_poke
    "date_trunc('hour', date) as date_time"
  end

  def self.payment_method_pokes
    "coalesce(payment_method, 'Not Defined') as payment_method"
  end

  def self.dimensions_customers
    "customers.id as customer_id, gtags.tag_uid as customer_uid, CONCAT(customers.first_name, ' ', customers.last_name) as customer_name"
  end

  def self.dimensions_operators_devices_simple
    "gtags.tag_uid as operator_uid, CONCAT(customers.first_name, ' ', customers.last_name) as operator_name, devices.asset_tracker as device_name"
  end

  def self.product_name
    "COALESCE(products.name, pokes.description) as product_name"
  end

  def self.grouping_customers
    "customers.id, customer_uid, customer_name"
  end

  def self.dimensions_operators_devices
    "operator_gtags_pokes.tag_uid as operator_uid, CONCAT(operators_pokes.first_name, ' ', operators_pokes.last_name) as operator_name, devices.asset_tracker as device_name"
  end

  def self.grouping_operators_devices
    "operator_uid, operator_name, device_name"
  end

  def self.dimensions_station
    "stations.location as location, stations.category as station_type, stations.name as station_name"
  end

  def self.grouping_station
    "location, station_type, station_name"
  end

  def self.sum_money
    "sum(monetary_total_price) as money"
  end

  def self.count_operations
    "count(operation_id) as num_operations"
  end

  def self.countd_operations
    "count(distinct operation_id) as num_operations"
  end

  def self.product_quantity
    "sum(sale_item_quantity) as sale_item_quantity"
  end

  def self.is_alcohol # rubocop:disable Naming/PredicateName
    "CASE WHEN products.is_alcohol = TRUE then 'Alcohol Product' ELSE 'Non' END as is_alcohol"
  end

  def self.access_capacity_query
    "CASE access_direction WHEN 1 THEN 'IN' WHEN -1 THEN 'OUT' END as direction,
    sum(sum(access_direction)) OVER (PARTITION BY access_direction ORDER BY date_trunc('hour', date) ) as capacity"
  end

  def self.access_capacity_all_query
    "CASE access_direction WHEN 1 THEN 'IN' WHEN -1 THEN 'OUT' END as direction,
    sum(access_direction) as access_direction,
    sum(CASE access_direction WHEN 1 THEN 1 ELSE 0 END) as direction_in,
    sum(CASE access_direction WHEN -1 THEN -1 ELSE 0 END) as direction_out,
    sum(sum(access_direction)) OVER (PARTITION BY #{sonar_access_patch_capacity}, access_direction ORDER BY date_trunc('hour', date) ) as capacity"
  end

  def self.balance
    "CASE
    WHEN description  = 'topup' then 'income'
    WHEN description  = 'purchase' then 'income'
    WHEN description  = 'refund' then 'refunds'
    WHEN description = 'record_credit' then 'income'
    ELSE action
    END as action"
  end

  def self.detail
    "CASE
    WHEN description  = 'record_credit' then 'redeemed_credits'
    WHEN description  = 'topup' then 'topup_onsite'
    WHEN description  = 'refund' then 'refund_onsite'
    ELSE description
    END as description"
  end

  def name # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize
    result = "#{action.humanize}: #{description.to_s.humanize}" if action.present? && description.present?
    result = action.humanize.to_s if action.present? && description.blank?
    result = "#{catalog_item.name.humanize} flag applied" if action.eql?("user_flag") && user_flag_value
    result = "#{catalog_item.name.humanize} flag removed" if action.eql?("user_flag") && !user_flag_value
    result = "Sale of #{sale_item_quantity} x #{product&.name}" if action.eql?("sale") && product
    result = "Sale of unknown product" if action.eql?("sale") && !product
    result = "Credit #{description.humanize.downcase}" if action.eql?("record_credit")
    result = "Monetary #{action.humanize.downcase}" if action.in?(%w[topup refund purchase])

    result
  end

  def error?
    !ok?
  end

  def ok?
    status_code.zero?
  end
end
