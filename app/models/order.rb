class Order < ActiveRecord::Base
  belongs_to :event
  belongs_to :customer, touch: true
  has_many :order_items, dependent: :destroy
  has_many :catalog_items, through: :order_items
  accepts_nested_attributes_for :order_items

  validates :number, :status, presence: true
  validate :max_credit_reached

  scope :in_progress, -> { where(status: "in_progress") }
  scope :completed, -> { where(status: "completed") }
  scope :cancelled, -> { where(status: "cancelled") }
  scope :failed, -> { where(status: "failed") }

  def refund?
    gateway.eql?("refund")
  end

  def complete!(gateway, payment)
    update!(status: "completed", gateway: gateway, completed_at: Time.zone.now, payment_data: payment)
  end

  def completed?
    status.eql?("completed")
  end

  def fail!(gateway, payment)
    update(status: "failed", gateway: gateway, payment_data: payment)
  end

  def cancel!(payment)
    update!(status: "cancelled", refund_data: payment)
  end

  def cancelled?
    status.eql?("cancelled")
  end

  def failed?
    status.eql?("failed")
  end

  def in_progress?
    status.eql?("in_progress")
  end

  def number
    id.to_s.rjust(7, "0")
  end

  def redeemed?
    order_items.pluck(:redeemed).all?
  end

  def total_formatted
    format("%.2f", total)
  end

  def total
    order_items.map(&:total).sum
  end

  def credits
    order_items.map(&:credits).sum
  end

  def refundable_credits
    order_items.map(&:refundable_credits).sum
  end

  private

  def max_credit_reached
    return unless customer
    return if cancelled?
    max_credits = customer.event.maximum_gtag_balance.to_f
    max_credits_reached = customer.orders.completed.map(&:credits).sum + credits > max_credits
    errors.add(:credits, I18n.t("errors.messages.max_credits_reached")) if max_credits_reached
  end
end
