require "spec_helper"

RSpec.describe Order, type: :model do
  let(:event) { build(:event) }
  subject { build(:order, event: event, customer: build(:customer, event: event)) }

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

  describe ".refunded?" do
    it "returns true if the gateway is refund" do
      expect(subject).not_to be_refunded
      subject.status = "refunded"
      expect(subject).to be_refunded
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
      expect(subject.number.size).to eq(7)

      subject.id = 122
      expect(subject.number.size).to eq(7)
    end
  end

  describe ".total_formatted" do
    it "returns the total formated" do
      allow(subject).to receive(:total).and_return(5)
      expect(subject.total_formatted).to eq("5.00")
    end
  end

  describe "order_item dependent methods" do
    before do
      @access = build(:order_item, :with_access, redeemed: false, total: 10, order: subject)
      @credit = build(:order_item, :with_credit, total: 20, order: subject)

      allow(subject).to receive(:order_items).and_return([@access, @credit])
    end

    describe ".redeemed?" do
      it "returns true if all the order_items are redeemed" do
        allow(subject).to receive(:order_items).and_return([@access])
        expect(subject).not_to be_redeemed
        @access.update(redeemed: true)
        expect(subject).to be_redeemed
      end
    end

    describe ".total" do
      it "returns the sum of the order_items total" do
        expect(subject.total).to eq(@access.total + @credit.total)
      end
    end

    describe ".credits" do
      it "returns the sum of the order_items credits" do
        allow(@access).to receive(:credits).and_return(10)
        allow(@credit).to receive(:credits).and_return(23)
        expect(subject.credits).to eq(33)
      end
    end

    describe ".refundable_credits" do
      it "returns the sum of the order_items refundable credits" do
        allow(@access).to receive(:refundable_credits).and_return(10)
        allow(@credit).to receive(:refundable_credits).and_return(23)

        expect(subject.refundable_credits).to eq(33)
      end
    end

    describe ".max_credit_reached" do
      it "adds an error if the credits exceeds the maximum allowed" do
        expect(subject).to be_valid
        subject.order_items << build(:order_item, :with_credit, amount: 100_000, order: subject)
        expect(subject).not_to be_valid
      end
    end
  end
end
