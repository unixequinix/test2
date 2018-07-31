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

    describe ".max_credit_reached" do
      it "adds an error if the credits exceeds the maximum allowed" do
        expect(subject).to be_valid
        subject.credits = 100_000
        expect { subject.save }.not_to change(subject, :credits)
        expect { subject.save }.to change(subject, :errors)
      end
    end
  end
end
