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

require "spec_helper"

RSpec.describe Refund, type: :model do
  subject { build(:refund) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  it "validates IBAN" do
    subject.iban = "000"
    expect(subject).not_to be_valid
  end

  it "validates SWIFT" do
    subject.swift = "000"
    expect(subject).not_to be_valid
  end

  describe ".total" do
    it "returns the sum of amount and fee" do
      subject.amount = 10
      subject.fee = 2
      expect(subject.total).to eq(12)
    end
  end

  describe ".number" do
    it "returns always the same size of digits in the refund number" do
      subject.id = 1
      expect(subject.number.size).to eq(12)

      subject.id = 122
      expect(subject.number.size).to eq(12)
    end
  end
end
