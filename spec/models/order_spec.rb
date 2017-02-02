# == Schema Information
#
# Table name: orders
#
#  completed_at :datetime
#  gateway      :string
#  payment_data :jsonb            not null
#  status       :string           default("in_progress"), not null
#
# Indexes
#
#  index_orders_on_customer_id  (customer_id)
#
# Foreign Keys
#
#  fk_rails_3dad120da9  (customer_id => customers.id)
#

require "spec_helper"

RSpec.describe Order, type: :model do
  subject { build(:order) }

  describe ".complete!" do
    it "marks the order as completed" do
      subject.complete!("paypal", {})
      expect(subject).to be_completed
    end
  end

  describe ".refund?" do
    it "returns true if the gateway is refund" do
      expect(subject).not_to be_refund
      subject.gateway = "refund"
      expect(subject).to be_refund
    end
  end

  describe ".completed?" do
    it "returns true if the status is completed" do
      subject.status = "completed"
      expect(subject).to be_completed
    end
  end

  describe ".fail!" do
    it "marks the order as faild" do
      subject.fail!("paypal", {})
      expect(subject.status).to eq("failed")
    end
  end

  describe ".cancel!" do
    it "marks the order as canceld" do
      subject.cancel!({})
      expect(subject.status).to eq("cancelled")
    end
  end

  describe ".cancelled?" do
    it "returns true if the status is cancelled" do
      subject.status = "cancelled"
      expect(subject).to be_cancelled
    end
  end

  describe ".number" do
    it "returns always the same size of digits in the order number" do
      subject.id = 1
      expect(subject.number.size).to eq(12)

      subject.id = 122
      expect(subject.number.size).to eq(12)
    end
  end

  describe ".redeemed?" do
    it "returns true if all the order_items are redeemed" do
      subject.order_items << build(:order_item, :with_access)
      subject.order_items.first.update(redeemed: false)
      subject.save
      expect(subject).not_to be_redeemed
      subject.order_items.first.update(redeemed: true)
      subject.reload
      expect(subject).to be_redeemed
    end
  end

  describe ".total_formated" do
    it "returns the total formated" do
      allow(subject).to receive(:total).and_return(5)
      expect(subject.total_formated).to eq("5.00")
    end
  end

  describe ".total" do
    it "returns the sum of the order_items total" do
      subject.order_items << build(:order_item, :with_access, total: 10)
      subject.order_items << build(:order_item, :with_access, total: 23)
      expect(subject.total).to eq(33)
    end
  end

  describe ".credits" do
    it "returns the sum of the order_items credits" do
      subject.order_items << build(:order_item, :with_credit, amount: 10)
      subject.order_items << build(:order_item, :with_credit, amount: 23)
      expect(subject.credits).to eq(33)
    end
  end

  describe ".refundable_credits" do
    it "returns the sum of the order_items refundable credits" do
      item1 = build(:order_item, :with_credit)
      allow(item1).to receive(:refundable_credits).and_return(10)
      item2 = build(:order_item, :with_credit)
      allow(item2).to receive(:refundable_credits).and_return(23)
      subject.order_items << item1
      subject.order_items << item2
      expect(subject.refundable_credits).to eq(33)
    end
  end

  describe ".max_credit_reached" do
    it "adds an error if the credits exceeds the maximum allowed" do
      expect(subject).to be_valid
      subject.order_items << build(:order_item, :with_credit, amount: 100_000)
      expect(subject).not_to be_valid
    end
  end
end
