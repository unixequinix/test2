class Refund < ApplicationRecord
  include Eventable
  include Creditable
  include Reportable

  attr_accessor :iban, :bsb

  belongs_to :event
  belongs_to :customer

  validates :gateway, presence: true
  validates :credit_fee, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :credit_base, presence: true, numericality: { greater_than: 0 }
  validate :extra_params_fields

  validate :correct_iban_and_swift, if: :iban
  validate :balance_checker

  validate_associations

  enum status: { started: 1, completed: 2, cancelled: 3 }

  scope :for_csv, -> { joins(:customer).select(:id, :credit_base, :credit_fee, :fields, "customers.first_name, customers.last_name, customers.email") }
  scope :with_gateway, ->(gateways) { gateways.present? ? where(gateway: gateways) : all }

  scope :online_refund, lambda {
    select(:customer_id, "min(created_at) as date", transaction_type_refund, dimension_operation_refund, dimensions_station, event_day_refund, date_time_refund, payment_method, count_operations, "-1 * sum(credit_base) as money")
      .completed
      .group(:customer_id, grouper_transaction_type, grouper_dimension_operation, grouper_dimensions_station, grouper_event_day, grouper_date_time, grouper_payment_method)
  }

  scope :online_refund_credits, lambda {
    select(:customer_id, "min(created_at) as date", transaction_type_refund, dimensions_station, event_day_refund, date_time_refund, count_operations, "'c' as credit_name, NULL as device_name", "-1 * sum(credit_base) as credit_amount")
      .completed
      .group(:customer_id, grouper_transaction_type, grouper_dimensions_station, grouper_event_day, grouper_date_time, "device_name")
  }

  scope :online_refund_fee, lambda {
    select(:customer_id, "min(created_at) as date", "'fee' as action, 'refund_online' as description, 'online' as source", dimensions_station, event_day_refund, date_time_refund, count_operations, "'c' as credit_name, NULL as device_name", "-1 * sum(credit_fee) as credit_amount")
      .completed.where('credit_fee != 0')
      .group(:customer_id, grouper_transaction_type, grouper_dimensions_station, grouper_event_day, grouper_date_time, "device_name")
  }

  def self.transaction_type_refund
    "'refunds' as action, 'Refund Online' as description, 'online' as source"
  end

  def self.dimension_operation_refund
    "NULL as operator_uid, 'Customer' operator_name, 'Customer Portal' as device_name"
  end

  def self.event_day_refund
    "to_char(date_trunc('day', created_at), 'YYYY-MM-DD') as event_day"
  end

  def self.date_time_refund
    "to_char(date_trunc('hour', created_at), 'YYYY-MM-DD HH24h') as date_time"
  end

  def self.count_operations
    "count(refunds.id) as num_operations"
  end

  def name
    "Refund: ##{id}"
  end

  def money_base
    credit_base * event.credit.value
  end

  def money_fee
    credit_fee * event.credit.value
  end

  def complete!(send_email = false)
    return false if completed?
    completed!
    OrderMailer.completed_refund(self).deliver_later if send_email && !customer.anonymous?
  end

  def cancel!(send_email = false)
    return false if cancelled?
    cancelled!
    OrderMailer.cancelled_refund(self).deliver_later if send_email && !customer.anonymous?
  end

  def prepare_for_bank_account(atts)
    return unless gateway.eql?("bank_account")
    self.fields = atts[:fields].to_h.each { |key, val| atts[:fields][key] = val.gsub(/\s+/, '') }
    self.iban = true if event.iban?
    self.bsb = true if event.bsb?
  end

  def correct_iban_and_swift
    validator = IBANTools::IBAN
    msg = validator.new(fields["IBAN"]).validation_errors.map(&:to_s).map(&:humanize).to_sentence
    errors.add(:iban, msg) unless validator.valid?(fields["IBAN"])
    validator = ISO::SWIFT.new(fields["SWIFT"])
    msg = validator.errors.map(&:to_s).map(&:humanize).to_sentence
    errors.add(:swift, msg) unless validator.valid?
  end

  def extra_params_fields
    event.refund_fields.each do |field|
      errors.add(:fields, "Field #{field} not found") if fields[field.to_s].blank?
    end
  end

  private

  def balance_checker
    return unless customer
    errors[:base] << "Customer does not have enough balance on the account" if completed? && customer.credits.to_f < credit_total.to_f
  end
end
