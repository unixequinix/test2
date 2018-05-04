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
  scope :record_credit, -> { where(action: "record_credit") }
  scope :not_record_credit, -> { where.not(description: "record_credit") }
  scope :credit_ops, -> { where(action: %w[record_credit sale]) }
  scope :fees, -> { where(action: 'fee') }
  scope :initial_fees, -> { where(action: "initial_fee") }
  scope :topup_fees, -> { where(action: "topup_fee") }
  scope :deposit_fees, -> { where(action: "gtag_deposit_fee") }
  scope :return_fees, -> { where(action: "gtag_return_fee") }
  scope :online_orders, -> { where(action: "record_credit", description: %w[record_credit order_applied_onsite]) }
  scope :has_money, -> { where.not(monetary_total_price: nil) }
  scope :has_credits, -> { where.not(credit_amount: nil) }
  scope :is_ok, -> { where(status_code: 0, error_code: nil) }
  scope :onsite, -> { where(source: "onsite") }
  scope :online, -> { where(source: "online") }

  scope :money_recon, lambda { |t = ''|
    select("CASE WHEN action = 'topup' THEN 'income' ELSE action END as action, action as description", :source, :payment_method, date_time_poke, dimensions_customers, dimensions_operators_devices, dimensions_station, sum_money, count_operations)
      .joins(:station, :device, :customer, :customer_gtag, :operator, :operator_gtag)
      .has_money.is_ok
      .where.not(payment_method: t)
      .group(:action, :description, :source, :payment_method, grouping_customers, grouping_operators_devices, grouping_station, "date_time")
  }

  scope :credit_flow, lambda {
    select(balance, detail, :credit_name, date_time_poke, dimensions_customers, dimensions_operators_devices, dimensions_station, "sum(credit_amount) as credit_amount, credit_name as payment_method", countd_operations)
      .joins(:station, :device, :customer, :customer_gtag, :operator, :operator_gtag)
      .where.not(credit_amount: nil).is_ok
      .group(:action, :description, :credit_name, grouping_customers, grouping_operators_devices, grouping_station, "date_time")
  }

  scope :products_sale, lambda { |credit|
    select(:action, :description, :credit_name, date_time_poke, dimensions_customers, dimensions_operators_devices, dimensions_station, is_alcohol, product_name, "sum(credit_amount)*-1 as credit_amount, credit_name as payment_method", count_operations, product_quantity)
      .joins(:station, :device, :customer, :customer_gtag, :operator, :operator_gtag).left_outer_joins(:product)
      .sales.is_ok
      .where(credit_id: credit)
      .group(:action, :description, :credit_name, grouping_customers, grouping_operators_devices, grouping_station, "date_time, is_alcohol, product_name")
  }

  scope :products_sale_stock, lambda {
    select(:operation_id, :description, :sale_item_quantity, "gtags.tag_uid as operator_uid, CONCAT(customers.first_name, ' ', customers.last_name) as operator_name, devices.asset_tracker as device_name", dimensions_station, date_time_poke, product_name)
      .joins(:station, :device, :operator, :operator_gtag).left_outer_joins(:product)
      .sales.is_ok
      .group(:operation_id, :description, :sale_item_quantity, grouping_operators_devices, grouping_station, "date_time, product_name")
  }

  scope :checkin_ticket_type, lambda {
    select(:action, :description, :ticket_type_id, dimensions_customers, dimensions_operators_devices, dimensions_station, date_time_poke, "devices.asset_tracker as device_name, catalog_items.name as catalog_item_name, ticket_types.name as ticket_type_name, count(pokes.id) as total_tickets")
      .left_outer_joins(:station, :device, :catalog_item, :customer, :customer_gtag, :operator, :operator_gtag, :ticket_type)
      .where(action: %w[checkin purchase]).is_ok
      .group(:action, :description, :ticket_type_id, grouping_customers, grouping_operators_devices, grouping_station, "date_time, device_name, catalog_item_name, ticket_type_name")
  }

  scope :access, lambda {
    select(date_time_poke, "stations.name as station_name, catalog_items.name as zone", access_capacity)
      .joins(:station, :catalog_item, :customer, :customer_gtag, :operator, :operator_gtag)
      .where.not(access_direction: nil).is_ok
      .group("station_name, date_time, catalog_item_id, zone, direction, access_direction")
  }

  scope :top_products, lambda {
    select(product_name, "row_number() OVER (ORDER BY  sum(credit_amount) ) as sorter, sum(credit_amount)*-1 as credits")
      .left_outer_joins(:product)
      .sales.is_ok
      .group("product_name")
      .order("credits desc")
      .limit(10)
  }

  has_paper_trail on: %i[update destroy]

  def self.date_time_poke
    "date_trunc('hour', date) as date_time"
  end

  def self.payment_method_pokes
    "coalesce(payment_method, 'Not Defined') as payment_method"
  end

  def self.dimensions_customers
    "customers.id as customer_id, gtags.tag_uid as customer_uid, CONCAT(customers.first_name, ' ', customers.last_name) as customer_name"
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

  def self.access_capacity
    "CASE access_direction WHEN 1 THEN 'IN' WHEN -1 THEN 'OUT' END as direction,
    sum(access_direction) as access_direction,
    sum(CASE access_direction WHEN 1 THEN 1 ELSE 0 END) as direction_in,
    sum(CASE access_direction WHEN -1 THEN -1 ELSE 0 END) as direction_out,
    sum(sum(access_direction))  OVER (PARTITION BY catalog_item_id, stations.name ORDER BY date_trunc('hour', date) ) as capacity"
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
