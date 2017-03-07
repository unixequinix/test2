class Refund < ActiveRecord::Base
  attr_accessor :validate_iban

  belongs_to :event
  belongs_to :customer
  validate :correct_iban_and_swift, if: :validate_iban
  validates :field_a, presence: true
  validates :field_b, presence: true

  scope :query_for_csv, lambda { |event|
    joins(:customer)
      .select("refunds.id, customers.email, customers.first_name, customers.last_name, refunds.amount, refunds.fee, refunds.money,
               refunds.status, refunds.field_a, refunds.field_b, refunds.created_at").where(customers: { event_id: event.id })
  }

  def total
    amount.to_f + fee.to_f
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

  def correct_iban_and_swift
    validator = IBANTools::IBAN
    msg = validator.new(field_a).validation_errors.map(&:to_s).map(&:humanize).to_sentence
    errors.add(:field_a, msg) unless validator.valid?(field_a)
    validator = ISO::SWIFT.new(field_b)
    msg = validator.errors.map(&:to_s).map(&:humanize).to_sentence
    errors.add(:field_b, msg) unless validator.valid?
  end
end
