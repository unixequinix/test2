class Poke < ApplicationRecord
  include Reportable

  belongs_to :event, counter_cache: true
  belongs_to :operation, class_name: "Transaction", optional: true, inverse_of: :pokes
  belongs_to :device, optional: true
  belongs_to :station, optional: true
  belongs_to :operator, class_name: "Customer", optional: true, inverse_of: :pokes_as_operator
  belongs_to :operator_gtag, class_name: "Gtag", optional: true, inverse_of: :pokes_as_operator
  belongs_to :customer, optional: true
  belongs_to :customer_gtag, class_name: "Gtag", optional: true, inverse_of: :pokes_as_customer
  belongs_to :ticket_type, optional: true
  belongs_to :company, optional: true
  belongs_to :product, optional: true
  belongs_to :catalog_item, optional: true
  belongs_to :order, optional: true
  belongs_to :credential, polymorphic: true, optional: true
  belongs_to :credit, polymorphic: true, optional: true

  scope :topups, -> { where(action: "topup") }
  scope :purchases, -> { where(action: "purchase") }
  scope :refunds, -> { where(action: "refund") }
  scope :sales, -> { where(action: "sale") }
  scope :record_credit, -> { where(action: "record_credit") }
  scope :sale_refunds, -> { where(action: "sale_refund") }
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

  scope :money_recon, lambda {
    select(:action, :description, :source, :payment_method, event_day_poke, "stations.category as station_type", "stations.name as station_name", sum_money)
      .left_joins(:station).has_money.is_ok
      .group(:action, :description, :source, :payment_method, "event_day, station_type, station_name")
  }

  scope :money_recon_operators, lambda {
    select(:action, :description, :source, :payment_method, event_day_poke, date_time_poke, dimensions_operators_devices, dimensions_station, sum_money)
      .left_joins(:station, :device, :operator).left_outer_joins(:operator_gtag).has_money.is_ok
      .group(:action, :description, :source, :payment_method, grouping_operators_devices, grouping_station, "date_time")
  }

  scope :products_sale, lambda {
    select(:description, :credit_name, event_day_poke, date_time_poke, dimensions_operators_devices, dimensions_station, "COALESCE(products.name, 'Other Amount') as product_name, sum(credit_amount)*-1 as credit_amount", "sum(sale_item_quantity) as sale_item_quantity")
      .joins(:station, :device, :operator).left_outer_joins(:operator_gtag, :product)
      .sales.is_ok
      .group(:description, :credit_name, grouping_operators_devices, grouping_station, "date_time", "product_name")
  }

  scope :products_sale_stock, lambda {
    select(:operation_id, :description, :sale_item_quantity, event_day_poke, dimensions_operators_devices, dimensions_station, "COALESCE(products.name, 'Other Amount') as product_name")
      .joins(:station, :device, :operator).left_outer_joins(:operator_gtag, :product)
      .sales.is_ok
      .group(:operation_id, :description, :sale_item_quantity, grouping_operators_devices, grouping_station, "product_name")
  }

  scope :top_products, lambda {
    select("COALESCE(products.name, 'Other Amount') as product_name, sum(credit_amount)*-1 as credit_amount")
      .left_outer_joins(:product)
      .sales.is_ok
      .group("product_name")
      .order("credit_amount desc")
      .limit(10)
  }

  scope :credit_flow, lambda {
    select(:action, :description, :credit_name, event_day_poke, date_time_poke, "stations.category as station_type, stations.name as station_name, devices.asset_tracker as device_name, sum(credit_amount) as credit_amount")
      .joins(:station, :device)
      .where.not(credit_amount: nil).is_ok
      .group(:action, :description, :credit_name, "event_day, date_time, station_type, station_name, device_name")
  }

  scope :checkin_ticket_type, lambda {
    select(:action, :description, event_day_poke, dimensions_station, date_time_poke, "devices.asset_tracker as device_name, catalog_items.name as catalog_item_name, ticket_types.name as ticket_type_name, count(pokes.id) as total_tickets, sum(pokes.monetary_total_price) as monetary_total_price")
      .joins(:station, :device, :catalog_item).left_joins(:ticket_type)
      .where(action: %w[checkin purchase]).is_ok
      .group(:action, :description, grouping_station, "event_day, date_time, device_name, catalog_item_name, ticket_type_name")
  }

  scope :access, lambda {
    select(event_day_poke, dimensions_station, date_time_poke, "CASE access_direction WHEN 1 THEN 'IN' WHEN -1 THEN 'OUT' END as direction", "sum(access_direction) as access_direction")
      .joins(:station)
      .where.not(access_direction: nil).is_ok
      .group(grouping_station, "event_day, date_time, direction")
  }

  scope :devices, -> { select("stations.name as station_name", event_day_poke, "count(distinct device_id) as total_devices").joins(:station).is_ok.group("stations.name", :event_day) }

  scope :record_credit_sale_h, lambda {
    select(date_time_poke, date_time_sort, "sum(CASE WHEN action = 'sale' then credit_amount ELSE 0 END) as sale, sum(CASE WHEN action = 'record_credit' then credit_amount ELSE 0 END) as record_credit")
      .credit_ops.is_ok
      .group("date_time_sort, date_time")
      .order("date_time_sort")
  }

  has_paper_trail on: %i[update destroy]

  def self.totals(event) # rubocop:disable Metrics/AbcSize
    {
      source_payment_method_money: event.pokes.select("source", payment_method_pokes, sum_money).is_ok.has_money.group("source, payment_method").as_json(except: :id),
      action_station_type_money: event.pokes.select("action, stations.category as station_type", sum_money).is_ok.has_money.joins(:station).group("action, station_type").as_json(except: :id),
      source_action_money: event.pokes.select("source, action", sum_money).is_ok.has_money.group("source, action").as_json(except: :id),

      credit_breakage: event.pokes.select("credit_name", sum_credits).is_ok.has_credits.group("credit_name"),
      credits_flow: event.pokes.select("action, description", sum_credits).is_ok.has_credits.group("action, description"),
      credits_type: event.pokes.select("action, credit_name", sum_credits).is_ok.has_credits.group("action, credit_name"),
      d_credits: event.pokes.record_credit_sale_h.is_ok.where(credit: event.credits).to_json,
      t_credits: event.pokes.select("credit_name", sum_credits).is_ok.where(credit: event.credits).group("credit_name").to_json,
      alcohol_products: event.pokes.select("CASE WHEN products.is_alcohol = TRUE then 'Alcohol Products' ELSE 'Non' END as is_alcohol, abs(sum(credit_amount)) as credits").is_ok.joins(:product).group("is_alcohol").to_json,
      top_productos: event.pokes.select("products.name as product_name, abs(sum(credit_amount)) as credits").is_ok.joins(:product).group("product_name").order("credits desc").limit("5").to_json
    }
  end

  def self.money_dashboard(event)
    {
      money_reconciliation: event.pokes.is_ok.sum(:monetary_total_price),
      income_onsite: event.pokes.topups.is_ok.where(credit: event.credits).sum(:credit_amount),
      refunds_onsite: event.pokes.is_ok.refunds.sum(:monetary_total_price).abs
    }
 end

  def self.dashboard(event)
    {
      money_reconciliation: event.pokes.is_ok.sum(:monetary_total_price),
      credits_breakage: event.pokes.is_ok.where(credit: event.credits).sum(:credit_amount),
      total_sales: event.pokes.is_ok.sales.where(credit: event.credits).sum(:credit_amount).abs,
      activations: event.customers.count
    }
  end

  def self.dashboard_graphs(event)
    {
      d_credits: event.pokes.record_credit_sale_h.is_ok.where(credit: event.credits).to_json
    }
  end

  def self.event_day_poke
    "to_char(date_trunc('day', date - INTERVAL '8 hour'), 'Mon-DD') as event_day"
  end

  def self.date_time_poke
    "to_char(date_trunc('hour', date), 'Mon-DD HH24h') as date_time"
  end

  def self.event_day_sort
    "date_trunc('day', date - INTERVAL '8 hour') as event_day_sort"
  end

  def self.date_time_sort
    "date_trunc('hour', date) as date_time_sort"
  end

  def self.payment_method_pokes
    "coalesce(payment_method, 'Not Defined') as payment_method"
  end

  def self.dimensions_operators_devices
    "gtags.tag_uid as operator_uid, CONCAT(customers.first_name, ' ', customers.last_name) as operator_name, devices.asset_tracker as device_name"
  end

  def self.grouping_operators_devices
    "event_day, operator_uid, operator_name, device_name"
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

  def self.sum_credits
    "sum(credit_amount) as credits"
  end

  def self.source_money
    "sum(CASE when source = 'online' THEN monetary_total_price ELSE NULL END) as online, sum(CASE when source = 'onsite' THEN monetary_total_price ELSE NULL END) as onsite"
  end

  def error?
    !ok?
  end

  def ok?
    status_code.zero?
  end
end
