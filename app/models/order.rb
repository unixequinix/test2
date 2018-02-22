class Order < ApplicationRecord
  include PokesHelper
  include Eventable
  include Creditable

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

  scope(:not_refund, -> { where.not(gateway: "refund") })

  enum status: { started: 1, in_progress: 2, completed: 3, refunded: 4, failed: 5, cancelled: 6 }

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
