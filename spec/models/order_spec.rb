require "rails_helper"

RSpec.describe Order, type: :model do
  let(:event) { create(:event) }
  let(:customer) { create(:customer, event: event) }
  subject { create(:order, event: event, customer: customer) }

  describe ".complete!" do
    before do
      event.stations.create! name: "Customer Portal", category: "customer_portal"
      @flag = event.user_flags.create!(name: "initial_topup")
    end

    it "marks the order as completed" do
      expect { subject.complete!("paypal", {}.to_json) }.to change { subject.reload.completed? }.from(false).to(true)
    end

    it "adds user flag to order if event has online_initial_topup_fee enabled" do
      event.update(online_initial_topup_fee: 2)
      expect(subject.catalog_items.user_flags).to be_empty
      subject.complete!("paypal", {}.to_json)
      expect(subject.catalog_items.user_flags).to eq([@flag])
    end

    it "does not add user flag to order if event has online_initial_topup_fee disabled" do
      event.update(online_initial_topup_fee: nil)
      expect(subject.catalog_items.user_flags).to be_empty
      subject.complete!("paypal", {}.to_json)
      expect(subject.catalog_items.user_flags).to be_empty
    end

    it "flag added must be initial_topup" do
      event.update(online_initial_topup_fee: 2)
      subject.complete!("paypal", {}.to_json)
      expect(subject.reload.catalog_items.user_flags.last.name).to eq("initial_topup")
    end

    it "changes customer initial_topup_fee_paid? to true" do
      event.update(online_initial_topup_fee: 2)
      expect { subject.complete!("paypal", {}.to_json) }.to change { customer.initial_topup_fee_paid }.from(false).to(true)
    end

    it "does not add flag if customer has already paid topup fee" do
      event.update!(online_initial_topup_fee: 2)
      customer.update!(initial_topup_fee_paid: true)
      expect { subject.complete!("paypal", {}.to_json) }.not_to change(subject.catalog_items.user_flags, :count)
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
      @access = build(:order_item, :with_access, redeemed: false, order: subject)
      @credit = build(:order_item, :with_credit, order: subject)

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
