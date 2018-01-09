class Order < ApplicationRecord
  include PokesHelper
  include Eventable

  belongs_to :event
  belongs_to :customer, touch: true

  has_many :order_items, dependent: :destroy, inverse_of: :order
  has_many :catalog_items, through: :order_items, dependent: :destroy
  has_many :transactions, dependent: :restrict_with_error

  accepts_nested_attributes_for :order_items

  validates :number, :status, presence: true

  validate :max_credit_reached

  validate_associations

  scope(:not_refund, -> { where.not(gateway: "refund") })

  enum status: { started: 1, in_progress: 2, completed: 3, refunded: 4, failed: 5, cancelled: 6 }

  def name
    "Order: ##{number}"
  end

  def complete!(gateway = "unknown", payment = {}.to_json, send_email = false)
    update!(status: "completed", gateway: gateway, completed_at: Time.zone.now, payment_data: payment)

    atts = { payment_method: gateway, payment_gateway: gateway, order_id: id, price: total }

    OrderMailer.completed_order(self).deliver_later if send_email && !customer.anonymous?
    MoneyTransaction.write!(event, "portal_purchase", :portal, customer, customer, atts)
  end

  def fail!(gateway, payment)
    update(status: "failed", gateway: gateway, payment_data: payment)
  end

  def cancel!(payment)
    update!(status: "cancelled", refund_data: payment)
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
    order_items.sum(&:total)
  end

  def credits
    order_items.sum(&:credits)
  end

  def virtual_credits
    order_items.sum(&:virtual_credits)
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
    max_credits_reached = customer.credits + credits > event.maximum_gtag_balance
    errors.add(:credits, I18n.t("alerts.max_credits_reached")) if max_credits_reached
  end
end
