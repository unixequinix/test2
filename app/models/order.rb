class Order < ApplicationRecord
  include PokesHelper
  include Eventable
  include Creditable
  include Reportable

  belongs_to :event
  belongs_to :customer, touch: true

  has_many :order_items, dependent: :destroy, inverse_of: :order
  has_many :catalog_items, through: :order_items, dependent: :destroy
  has_many :transactions, dependent: :restrict_with_error

  accepts_nested_attributes_for :order_items, allow_destroy: true

  validates :number, :status, presence: true
  validates :order_items, presence: true
  validates :money_fee, :money_base, numericality: { greater_than_or_equal_to: 0 }, presence: true

  validate :max_credit_reached

  validate_associations

  enum status: { started: 1, in_progress: 2, completed: 3, refunded: 4, failed: 5, cancelled: 6 }

  scope :has_money, -> { where.not(money_base: nil) }
  scope :not_refund, -> { where.not(gateway: "refund") }
  scope :with_gateway, ->(gateways) { gateways.present? ? where(gateway: gateways) : all }

  scope :online_purchase, lambda {
    select(:customer_id, "min(completed_at) as date", transaction_type, dimension_operation, dimensions_station, event_day_order, date_time_order, payment_method, countd_operations, "sum(money_base) as money")
      .completed
      .group(:customer_id, grouper_transaction_type, grouper_dimension_operation, grouper_dimensions_station, grouper_event_day, grouper_date_time, grouper_payment_method)
      .having("sum(money_base)!=0")
  }

  scope :online_purchase_fee, lambda {
    select(:customer_id, "min(completed_at) as date", event_day_order, date_time_order, dimensions_station, payment_method, countd_operations, "'fee' as action, 'online_applied_fee' as description, NULL as device_name, 'x' as credit_name", "sum(money_fee) as money")
      .completed
      .group(:customer_id, grouper_event_day, grouper_date_time, grouper_dimensions_station, grouper_payment_method, "action, description, device_name, credit_name")
      .having("sum(money_fee)!=0")
  }

  scope :online_topup, lambda {
    select(:customer_id, "min(completed_at) as date", event_day_order, date_time_order, dimensions_station, countd_operations, "'income' as action, 'unredeemed_topup_online' as description, NULL as device_name, catalog_items.name as credit_name, sum(order_items.amount) as credit_amount")
      .joins(order_items: :catalog_item)
      .where(catalog_items: { type: %w[Credit VirtualCredit], order_items: { redeemed: false } })
      .completed
      .group(:customer_id, grouper_event_day, grouper_date_time, grouper_dimensions_station, "action, description, device_name, credit_name")
  }

  def self.online_packs(event)
    connection.select_all("SELECT
    1 as id,
    customer_id,
    MIN(completed_at) as date,
    to_char(date_trunc('day', completed_at), 'YYYY-MM-DD') as event_day,
    to_char(date_trunc('hour', completed_at), 'YYYY-MM-DD HH24h') as date_time,
    'Customer Portal' as location,
    'Customer Portal' as station_type,
    'Customer Portal' as station_name,
    'income' as action,
    'unredeemed_purchase_online' as description,
     NULL as device_name,
      item2.name as credit_name,
      count(distinct orders.id) as num_operations,
      sum(o.amount * i.amount) as credit_amount
    FROM orders
      JOIN order_items o ON orders.id = o.order_id
      JOIN catalog_items item ON o.catalog_item_id = item.id
      JOIN pack_catalog_items i ON item.id = i.pack_id
      JOIN catalog_items item2 ON i.catalog_item_id = item2.id
      AND item.type in ('Pack')
      AND item2.type in ('Credit', 'VirtualCredit')
      AND item.event_id = #{event.id}
      AND orders.status = #{statuses[:completed]}
      AND o.redeemed = FALSE
    GROUP BY customer_id, event_day, date_time, location, station_type, station_name, action, description, device_name, credit_name")
  end

  def topup?
    # event.catalog_items.where(id: order_items.pluck(:catalog_item_id)).select(:type).distinct.pluck(:type).all? { |klass| klass.include?("Credit") }
    order_items.includes(:catalog_item).all? { |item| item.catalog_item.class.to_s.include?("Credit") }
  end

  def purchase?
    !topup?
  end

  def self.event_day_order
    "to_char(date_trunc('day', completed_at), 'YYYY-MM-DD') as event_day"
  end

  def self.event_day_sort_order
    "date_trunc('day', completed_at) as event_day_sort"
  end

  def self.date_time_order
    "to_char(date_trunc('hour', completed_at), 'YYYY-MM-DD HH24h') as date_time"
  end

  def self.sum_credits
    "sum(order_items.amount) as credit_amount"
  end

  def self.transaction_type
    "'income' as action, 'online_purchase' as description, 'online' as source"
  end

  def self.countd_operations
    "count(distinct orders.id) as num_operations"
  end

  def name
    "Order: ##{number}"
  end

  def credit_base
    (money_base / event.credit.value).round(2)
  end

  def credit_fee
    (money_fee / event.credit.value).round(2)
  end

  def set_counters
    last_counter = customer.order_items.maximum(:counter).to_i
    order_items.each.with_index { |item, index| item.counter = last_counter + index + 1 }
    self
  end

  def complete!(gateway = "unknown", payment = {}.to_json, send_email = false)
    update!(status: "completed", gateway: gateway, completed_at: Time.zone.now, payment_data: payment)
    OrderMailer.completed_order(self).deliver_later if send_email && !customer.anonymous?

    return unless event.online_initial_topup_fee.present? && !customer.initial_topup_fee_paid?
    flag = event.user_flags.find_by(name: "initial_topup")
    order_items.create!(catalog_item: flag, amount: 1, counter: customer.order_items.maximum(:counter).to_i + 1)
    customer.update!(initial_topup_fee_paid: true)
  end

  def redeemed?
    order_items.pluck(:redeemed).all?
  end

  private

  def max_credit_reached
    return unless customer
    return if cancelled?
    max_credits_reached = customer.credits + credits > event.maximum_gtag_balance
    errors.add(:credits, I18n.t("alerts.max_credits_reached")) if max_credits_reached
  end
end
