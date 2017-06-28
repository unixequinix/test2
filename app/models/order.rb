class Order < ApplicationRecord
  belongs_to :event
  belongs_to :customer, touch: true

  has_many :order_items, dependent: :destroy, inverse_of: :order
  has_many :catalog_items, through: :order_items
  has_many :transactions, dependent: :restrict_with_error

  accepts_nested_attributes_for :order_items

  validates :number, :status, presence: true

  validate :max_credit_reached

  # TODO: Change this to enum
  scope(:not_refund, -> { where.not(gateway: "refund") })
  scope(:in_progress, -> { where(status: "in_progress") })
  scope(:completed, -> { where(status: "completed") })
  scope(:refunded, -> { where(status: "refunded") })
  scope(:cancelled, -> { where(status: "cancelled") })
  scope(:failed, -> { where(status: "failed") })

  def refund?
    gateway.eql?("refund")
  end

  def refunded?
    status.eql?("refunded")
  end

  def complete!(gateway = "unknown", payment = {}.to_json)
    update!(status: "completed", gateway: gateway, completed_at: Time.zone.now, payment_data: payment)
    atts = { payment_method: gateway, payment_gateway: gateway, order_id: id, price: total }
    MoneyTransaction.write!(event, "portal_purchase", :portal, customer, customer, atts)
    OrderMailer.completed_order(self).deliver_later unless customer.anonymous?
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

  def online_refund(amount)
    case gateway
      when "paypal" then
        paypal = ActiveMerchant::Billing::PaypalExpressGateway.new(event.payment_gateways.paypal.first.data.symbolize_keys)
        paypal.refund(amount * 100, payment_data["PaymentInfo"]["TransactionID"], currency: event.currency)
    end
  end

  private

  def max_credit_reached
    return unless customer
    return if cancelled?
    max_credits_reached = customer.global_credits + credits > event.maximum_gtag_balance
    errors.add(:credits, I18n.t("alerts.max_credits_reached")) if max_credits_reached
  end
end
