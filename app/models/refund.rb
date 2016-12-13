# == Schema Information
#
# Table name: refunds
#
#  amount      :decimal(8, 2)    not null
#  fee         :decimal(8, 2)
#  iban        :string
#  money       :decimal(8, 2)
#  status      :string
#  swift       :string
#
# Indexes
#
#  index_refunds_on_customer_id  (customer_id)
#
# Foreign Keys
#
#  fk_rails_6a4a43dcc1  (customer_id => customers.id)
#

class Refund < ActiveRecord::Base
  belongs_to :customer

  validates :iban, :swift, presence: true
  validate :valid_iban
  validate :valid_swift

  scope :query_for_csv, lambda { |event|
    joins(:customer)
      .select("refunds.id, customers.email, refunds.amount, refunds.fee, refunds.money, refunds.status, refunds.iban,
               refunds.swift, refunds.created_at").where(customers: { event_id: event.id })
  }

  def total
    amount.to_f + fee.to_f
  end

  def number
    id.to_s.rjust(12, "0")
  end

  private

  def valid_swift
    validator = ISO::SWIFT.new(swift)
    msg = validator.errors.map(&:to_s).map(&:humanize).to_sentence
    errors.add(:swift, msg) unless validator.valid?
  end

  def valid_iban
    validator = IBANTools::IBAN
    msg = validator.new(iban).validation_errors.map(&:to_s).map(&:humanize).to_sentence
    errors.add(:iban, msg) unless validator.valid?(iban)
  end
end
