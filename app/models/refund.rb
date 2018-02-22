class Refund < ApplicationRecord
  include Eventable
  include Creditable

  attr_accessor :iban, :bsb

  belongs_to :event, counter_cache: true
  belongs_to :customer

  validates :gateway, presence: true
  validates :credit_fee, :credit_base, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :extra_params_fields

  validate :correct_iban_and_swift, if: :iban
  validate :balance_checker

  validate_associations

  enum status: { started: 1, completed: 2, cancelled: 3 }

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
    msg = validator.new(fields[:iban]).validation_errors.map(&:to_s).map(&:humanize).to_sentence
    errors.add(:iban, msg) unless validator.valid?(fields[:iban])
    validator = ISO::SWIFT.new(fields[:swift])
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
    errors[:base] << "Customer does not have enough balance on the account" if completed? && customer.credits < credit_total
  end
end
