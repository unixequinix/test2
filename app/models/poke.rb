class Poke < ApplicationRecord
  belongs_to :event
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
  scope :refunds, -> { where(action: "refund") }
  scope :sales, -> { where(action: "sale") }
  scope :sale_refunds, -> { where(action: "sale_refund") }
  scope :initial_fees, -> { where(action: "initial_fee") }
  scope :topup_fees, -> { where(action: "topup_fee") }
  scope :deposit_fees, -> { where(action: "gtag_deposit_fee") }
  scope :return_fees, -> { where(action: "gtag_return_fee") }

  scope :has_money, -> { where.not(monetary_total_price: nil) }
  scope :is_ok, -> { where(status_code: 0, error_code: nil) }

  scope :onsite, -> { where(source: "onsite") }
  scope :online, -> { where(source: %w[customer_portal admin_panel]) }

  scope :money_recon, lambda {
    select(:action, :description, :payment_method, event_day_query_as_event_day, "stations.category as station_type", "stations.name as station_name", "sum(monetary_total_price) as monetary_total_price") # rubocop:disable Metrics/LineLength
      .joins(:station).has_money.is_ok
      .group(:action, :description, :payment_method, "#{event_day_query}, station_type, station_name")
  }

  scope :money_recon_operators, lambda {
    select(:action, :description, :payment_method, event_day_query_as_event_day, dimensions_operators_devices, dimensions_station, "sum(monetary_total_price) as monetary_total_price") # rubocop:disable Metrics/LineLength
      .joins(:station, :device, :operator).left_outer_joins(:operator_gtag).has_money.is_ok
      .group(:action, :description, :payment_method, grouping_operators_devices, grouping_station)
  }

  scope :products_sale, lambda {
    select(:description, :credit_name, event_day_query_as_event_day, dimensions_operators_devices, dimensions_station, "COALESCE(products.name, 'Other Amount') as product_name, sum(credit_amount)*-1 as credit_amount", "sum(sale_item_quantity) as sale_item_quantity") # rubocop:disable Metrics/LineLength
      .joins(:station, :device, :operator).left_outer_joins(:operator_gtag, :product)
      .where(action: 'sale').is_ok
      .group(:description, :credit_name, grouping_operators_devices, grouping_station, "product_name")
  }

  scope :products_sale_stock, lambda {
    select(:operator_id, :description, :sale_item_quantity, event_day_query_as_event_day, dimensions_operators_devices, dimensions_station, "COALESCE(products.name, 'Other Amount') as product_name") # rubocop:disable Metrics/LineLength
      .joins(:station, :device, :operator).left_outer_joins(:operator_gtag, :product)
      .where(action: 'sale').is_ok
      .group(:operator_id, :description, :sale_item_quantity, grouping_operators_devices, grouping_station, "product_name")
  }

  scope :credit_flow, lambda {
    select(:action, :description, :credit_name, event_day_query_as_event_day, "stations.category as station_type, stations.name as station_name, devices.asset_tracker as device_name, sum(credit_amount) as credit_amount") # rubocop:disable Metrics/LineLength
      .joins(:station, :device)
      .where.not(credit_amount: nil).is_ok
      .group(:action, :description, :credit_name, "#{event_day_query}, station_type, station_name, device_name")
  }

  scope :checkin_ticket_type, lambda {
    select(:action, :description, event_day_query_as_event_day, "stations.category as station_type, stations.name as station_name, devices.asset_tracker as device_name, ticket_types.name as ticket_type_name, count(pokes.id) as total_tickets") # rubocop:disable Metrics/LineLength
      .joins(:station, :ticket_type, :device)
      .where(action: %w[checkin checkpoint]).is_ok
      .group(:action, :description, "#{event_day_query}, station_type, station_name, device_name, ticket_type_name")
  }

  scope :access, lambda {
    select(event_day_query_as_event_day, dimensions_station, "to_char(date_trunc('hour', date), 'DD-MM-YYYY HHh') as date_time, CASE access_direction WHEN 1 THEN 'IN' WHEN -1 THEN 'OUT' END as direction", "sum(access_direction) as access_direction") # rubocop:disable Metrics/LineLength
      .joins(:station)
      .where.not(access_direction: nil).is_ok
      .group(grouping_station, "#{event_day_query}, date_time, direction")
  }

  scope :devices, -> { select("stations.name as station_name", event_day_query_as_event_day, "count(distinct device_id) as total_devices").joins(:station).is_ok.group("stations.name", :event_day) } # rubocop:disable Metrics/LineLength

  has_paper_trail on: %i[update destroy]

  def self.event_day_query_as_event_day
    "#{event_day_query}  as event_day"
  end

  def self.event_day_query
    "to_char(date_trunc('day', date - INTERVAL '8 hour'), 'DD-MM-YYYY')"
  end

  def self.dimensions_operators_devices
    "gtags.tag_uid as operator_uid, CONCAT(customers.first_name, ' ', customers.last_name) as operator_name, devices.asset_tracker as device_name" # rubocop:disable Metrics/LineLength
  end

  def self.grouping_operators_devices
    "#{event_day_query}, operator_uid, operator_name, device_name"
  end

  def self.dimensions_station
    "stations.location as location, stations.category as station_type, stations.name as station_name"
  end    

  def self.grouping_station
    "location, station_type, station_name"
  end

  def error?
    !ok?
  end

  def ok?
    status_code.zero?
  end
end
