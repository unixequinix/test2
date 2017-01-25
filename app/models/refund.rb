# == Schema Information
#
# Table name: refunds
#
#  amount      :decimal(8, 2)    not null
#  fee         :decimal(8, 2)
#  field_a     :string
#  field_b     :string
#  money       :decimal(8, 2)
#  status      :string
#
# Indexes
#
#  index_refunds_on_customer_id  (customer_id)
#  index_refunds_on_event_id     (event_id)
#
# Foreign Keys
#
#  fk_rails_6a4a43dcc1  (customer_id => customers.id)
#  fk_rails_ab1c98fb18  (event_id => events.id)
#

class Refund < ActiveRecord::Base
  attr_accessor :validate_iban

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

  def number
    id.to_s.rjust(12, "0")
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
