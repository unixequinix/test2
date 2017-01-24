# == Schema Information
#
# Table name: orders
#
#  completed_at :datetime
#  gateway      :string
#  payment_data :jsonb            not null
#  status       :string           default("in_progress"), not null
#
# Indexes
#
#  index_orders_on_customer_id  (customer_id)
#  index_orders_on_event_id     (event_id)
#
# Foreign Keys
#
#  fk_rails_3dad120da9  (customer_id => customers.id)
#  fk_rails_64bd9e45d4  (event_id => events.id)
#

class Order < ActiveRecord::Base
  default_scope { order(created_at: :desc) }

  belongs_to :customer, touch: true
  has_many :order_items, dependent: :destroy
  has_many :catalog_items, through: :order_items, class_name: "CatalogItem"
  accepts_nested_attributes_for :order_items

  validates :number, :status, presence: true
  validate :max_credit_reached

  scope :in_progress, -> { where(status: "in_progress") }
  scope :completed, -> { where(status: "completed") }
  scope :cancelled, -> { where(status: "cancelled") }
  scope :failed, -> { where(status: "failed") }

  before_create :set_counters

  def refund?
    gateway.eql?("refund")
  end

  def complete!(gateway, payment)
    update(status: "completed", gateway: gateway, completed_at: Time.zone.now, payment_data: payment)
  end

  def completed?
    status.eql?("completed")
  end

  def fail!(gateway, payment)
    update(status: "failed", gateway: gateway, payment_data: payment)
  end

  def cancel!(payment)
    update(status: "cancelled", payment_data: payment)
  end

  def cancelled?
    status.eql?("cancelled")
  end

  def number
    id.to_s.rjust(12, "0")
  end

  def redeemed?
    order_items.pluck(:redeemed).all?
  end

  def total_formated
    format("%.2f", total)
  end

  def total
    order_items.to_a.sum(&:total)
  end

  def credits
    order_items.to_a.sum(&:credits)
  end

  def refundable_credits
    order_items.to_a.sum(&:refundable_credits)
  end

  private

  def set_counters
    last_counter = customer.order_counters.last.to_i
    order_items.each.with_index { |item, index| item.counter = index + last_counter + 1 }
  end

  def max_credit_reached
    return unless customer
    max_credits = customer.event.maximum_gtag_balance.to_f
    max_credits_reached = customer.orders.map(&:credits).sum + credits > max_credits
    errors.add(:credits, I18n.t("errors.messages.max_credits_reached")) if max_credits_reached
  end
end
