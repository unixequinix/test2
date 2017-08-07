require "rails_helper"

RSpec.describe Transactions::Base, type: :job do
  let(:base)  { Transactions::Base }
  let(:event) { create(:event) }
  let(:gtag)  { create(:gtag, tag_uid: "AAAAAAAAAAAAAA", event: event) }
  let(:customer) { create(:customer, event: event) }
  let(:atts) do
    {
      type: "credit",
      action: "test_action",
      credits: 30,
      event_id: event.id,
      device_created_at: Time.zone.now.to_s,
      customer_tag_uid: gtag.tag_uid,
      status_code: 0
    }
  end

  describe "when sale_items_attributes is blank" do
    after do
      expect { base.perform_now(atts) }.to change(Transaction, :count).by(1)
    end

    it "works when status code is error (other than 0)" do
      atts[:status_code] = 2
    end

    it "removes sale_item_attributes when empty" do
      atts[:sale_item_attributes] = []
    end

    it "removes sale_item_attributes when nil" do
      atts[:sale_item_attributes] = nil
    end
  end

  describe "when passed sale_items in attributes" do
    before do
      atts.merge!(sale_items_attributes: [{ product_id: create(:product).id, quantity: 1.0, unit_price: 8.31 },
                                          { product_id: create(:product).id, quantity: 1.0, unit_price: 2.72 }])
    end

    it "saves sale_items" do
      expect { base.perform_now(atts) }.to change(SaleItem, :count).by(2)
    end
  end

  describe "descendants" do
    it "executes the job defined by action" do
      expected_atts = { action: "sale", event_id: event.id, type: "CreditTransaction", credits: 30, customer_tag_uid: gtag.tag_uid, status_code: 0 }
      atts[:action] = "sale"
      expect(Transactions::Credit::BalanceUpdater).to receive(:perform_later).once.with(hash_including(expected_atts))
      allow(Transactions::Stats::SaleCreator).to receive(:perform_later).once
      base.perform_now(atts)
    end

    it "must be loaded with environment" do
      expect(base.descendants).not_to be_empty
    end

    it "should include the descendants of base classes" do
      expect(base.descendants).to include(Transactions::Credential::TicketChecker)
      expect(base.descendants).to include(Transactions::Credential::GtagChecker)
      expect(base.descendants).to include(Transactions::Credit::BalanceUpdater)
    end
  end

  context "creating transactions" do
    describe "from devices" do
      it "ignores attributes not present in table" do
        expect do
          base.perform_now(atts.merge(foo: "not valid"))
        end.to change(CreditTransaction, :count).by(1)
      end

      it "works even if jobs fail" do
        atts[:action] = "sale"
        allow(Transactions::Credit::BalanceUpdater).to receive(:perform_later).and_raise("Error_1")
        expect { base.perform_now(atts) }.to raise_error("Error_1")
        atts.delete(:transaction_id)
        atts.delete(:customer_id)
        atts.delete(:device_created_at)
        atts.delete(:type)

        expect(CreditTransaction.where(atts)).not_to be_empty
      end
    end
  end

  context "executing subscriptors" do
    it "should only execute subscriptors if the transaction created is new" do
      atts[:action] = "sale"
      expect(Transactions::Credit::BalanceUpdater).to receive(:perform_later).once
      allow(Transactions::Stats::SaleCreator).to receive(:perform_later).once
      base.perform_now(atts)
      at = atts.merge(type: "credit", device_created_at: atts[:device_created_at])
      base.perform_now(at)
    end
  end
end
