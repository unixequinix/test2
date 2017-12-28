require "rails_helper"

RSpec.describe Order, type: :model do
  let(:event) { create(:event) }
  subject { create(:order, event: event, customer: create(:customer, event: event)) }

  describe ".complete!" do
    before { event.stations.create! name: "Customer Portal", category: "customer_portal" }

    it "marks the order as completed" do
      expect { subject.complete!("paypal", {}.to_json) }.to change { subject.reload.completed? }.from(false).to(true)
    end

    it "creates a money transaction" do
      expect { subject.complete!("paypal", {}.to_json) }.to change(MoneyTransaction, :count).by(1)
    end
  end

  describe ".refund?" do
    it "returns true if the gateway is refund" do
      expect { subject.gateway = "refund" }.to change { subject.refund? }.from(false).to(true)
    end
  end

  describe ".refunded?" do
    it "returns true if the gateway is refund" do
      expect { subject.status = "refunded" }.to change { subject.refunded? }.from(false).to(true)
    end
  end

  describe ".completed?" do
    it "returns true if the status is completed" do
      expect { subject.status = "completed" }.to change { subject.completed? }.from(false).to(true)
    end
  end

  describe ".fail!" do
    it "marks the order as faild" do
      expect { subject.fail!("paypal", {}.to_json) }.to change { subject.reload.status }.to("failed")
    end
  end

  describe ".cancel!" do
    it "marks the order as canceld" do
      expect { subject.cancel!({}.to_json) }.to change { subject.reload.status }.to("cancelled")
    end
  end

  describe ".cancelled?" do
    it "returns true if the status is cancelled" do
      expect { subject.status = "cancelled" }.to change { subject.cancelled? }.from(false).to(true)
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

    describe ".virtual_credits" do
      it "returns the sum of the order_items virtual credits" do
        allow(@access).to receive(:virtual_credits).and_return(10)
        allow(@credit).to receive(:virtual_credits).and_return(23)

        expect(subject.virtual_credits).to eq(33)
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
