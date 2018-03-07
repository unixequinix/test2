class Order < ApplicationRecord
  include PokesHelper
  include Eventable
  include Creditable
  include Reportable

  belongs_to :event, counter_cache: true
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

  scope :completed, -> { where(status: "completed") }
  scope :has_money, -> { where.not(money_base: nil) }
  scope(:not_refund, -> { where.not(gateway: "refund") })

  # TODO: diferentiate top-up, purchase and fees
  scope :online_purchase, lambda {
    select(transaction_type, dimension_operation, dimensions_station, event_day_order, date_time_order, payment_method, "sum(money_base + money_fee) as money")
      .completed
      .group(grouper_transaction_type, grouper_dimension_operation, grouper_dimensions_station, grouper_event_day, grouper_date_time, grouper_payment_method)
  }

  scope :online_credits, lambda {
    select("sum(order_items.amount)").joins(:order_items)
  }

  def topup?
    # event.catalog_items.where(id: order_items.pluck(:catalog_item_id)).select(:type).distinct.pluck(:type).all? { |klass| klass.include?("Credit") }
    order_items.all? { |item| item.catalog_item.class.to_s.include?("Credit") }
  end

  def purchase?
    !topup?
  end

  def self.dashboard(event)
    {
      money_reconciliation: event.orders.completed.sum(:money_base),
      credits_breakage: OrderItem.where(order: event.orders.completed, catalog_item: event.credit).sum(:amount)
    }
  end

  def self.totals(event)
    {
      source_payment_method_money: event.orders.select("'online' as source", payment_method, money_order).completed.has_money.group("source, payment_method").as_json(except: :id),
      action_station_type_money: event.orders.select("'purchase' as action, 'Customer Portal' as station_type", money_order).completed.has_money.group("action, station_type").as_json(except: :id),
      source_action_money: event.orders.select("'online' as source, 'purchase' as action", money_order).completed.has_money.group("source, action").as_json(except: :id)
    }
  end

  def self.money_dashboard(event)
    {
      income_online: event.orders.sum(:money_base),
      unreedemed_online_money: event.orders.includes(:order_items).where(order_items: { redeemed: false }).sum(:money_base)
    }
  end

  def self.event_day_order
    "to_char(date_trunc('day', completed_at), 'Mon-DD') as event_day"
  end

  def self.event_day_sort_order
    "date_trunc('day', completed_at) as event_day_sort"
  end

  def self.date_time_order
    "to_char(date_trunc('hour', completed_at), 'Mon-DD HH24h') as date_time"
  end

  def self.money_order
    "sum(money_base + money_fee) as money"
  end

  def self.transaction_type
    "'purchase' as action, 'Online Purchase' as description, 'online' as source"
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

  def credits
    order_items.sum(&:credits)
  end

  def virtual_credits
    order_items.sum(&:virtual_credits)
  end

  private

  def max_credit_reached
    return unless customer
    return if cancelled?
    max_credits_reached = customer.credits + credits > event.maximum_gtag_balance
    errors.add(:credits, I18n.t("alerts.max_credits_reached")) if max_credits_reached
  end
end
