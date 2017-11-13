class Refund < ApplicationRecord
  include Eventable

  attr_accessor :iban, :bsb

  belongs_to :event
  belongs_to :customer

  validates :field_a, length: { is: 6 }, bsb_number: true, if: :bsb
  validates :field_b, length: { within: 6..10 }, if: :bsb
  validates :fee, numericality: { greater_than_or_equal_to: 0 }, presence: true
  validates :field_a, :field_b, presence: true, if: (-> { gateway.eql?("bank_account") })
  validate :extra_params_fields
  validates :amount, :gateway, presence: true

  validate :correct_iban_and_swift, if: :iban

  validate_associations

  scope(:query_for_csv, lambda { |event|
    joins(:customer)
      .select("refunds.id, customers.email, customers.first_name, customers.last_name, refunds.amount, refunds.fee,
               refunds.status, refunds.field_a, refunds.field_b, refunds.created_at, refunds.ip").where(customers: { event_id: event.id })
  })

  def complete!(refund_data = {}.to_json)
    return false if completed?
    update!(status: "completed")

    atts = { items_amount: amount_money, payment_gateway: gateway, payment_method: "online", price: total_money }
    MoneyTransaction.write!(event, "online_refund", :portal, customer, customer, atts)

    # Create negative online order (to be replaced by tasks/transactions or start downloading refunds)
    order = customer.build_order([[event.credit.id, -total]])
    order.update!(status: "refunded", gateway: gateway, completed_at: Time.zone.now, payment_data: refund_data)

    OrderMailer.completed_refund(self).deliver_later
  end

  def prepare_for_bank_account(atts)
    return unless gateway.eql?("bank_account")
    self.field_a = atts[:field_a].gsub(/\s+/, '')
    self.field_b = atts[:field_b].gsub(/\s+/, '')
    self.extra_params = atts[:extra_params].to_h.each { |key, val| atts[:extra_params][key] = val.gsub(/\s+/, '') }
    self.iban = true if event.iban?
    self.bsb = true if event.bsb?
  end

  # TODO: Change this to enum
  def completed?
    status.eql?("completed")
  end

  def total
    amount + fee
  end

  def amount_money
    amount * event.credit.value
  end

  def fee_money
    fee * event.credit.value
  end

  def total_money
    total * event.credit.value
  end

  def number
    id.to_s.rjust(7, "0")
  end

  def execute_refund_of_orders
    orders = customer.orders.completed.where(gateway: gateway).sort_by(&:total).reverse.to_a

    reduce_orders(orders, amount_money).map do |order, amount|
      response = order.online_refund(amount)
      order.update!(status: "refunded", refund_data: response.params.to_json) if response.success?
    end
  end

  def reduce_orders(orders, amount)
    order = orders.shift
    return [] unless order
    return [[order, amount]] if order.total > amount
    [[order, order.total]] + reduce_orders(orders, amount - order.total)
  end

  def correct_iban_and_swift
    validator = IBANTools::IBAN
    msg = validator.new(field_a).validation_errors.map(&:to_s).map(&:humanize).to_sentence
    errors.add(:field_a, msg) unless validator.valid?(field_a)
    validator = ISO::SWIFT.new(field_b)
    msg = validator.errors.map(&:to_s).map(&:humanize).to_sentence
    errors.add(:field_b, msg) unless validator.valid?
  end

  def extra_params_fields
    return if event.payment_gateways&.bank_account.blank?
    event.payment_gateways.bank_account.extra_fields.each do |field|
      errors.add(:extra_params, "Field #{field} not found") if extra_params[field.to_s].blank?
    end
  end
end
