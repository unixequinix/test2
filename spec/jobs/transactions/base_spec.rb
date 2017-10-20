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

  before { Transactions::Credit::BalanceUpdater }

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

  describe "descendants" do
    before { atts[:transaction_id] = create(:credit_transaction, event: event).id }
    after { base.execute_descendants(atts) }

    it "should have all classes loaded" do
      expect(base.descendants).not_to be_empty
    end

    it "should call perform_later on a subscriber class" do
      atts[:action] = "sale"
      expect(Transactions::Credit::BalanceUpdater).to receive(:perform_later).once
    end

    it "should not call perform_later on anything if there is no subscriber" do
      expect(Transactions::Credit::BalanceUpdater).not_to receive(:perform_later)
    end

    it "should call execute_descendants on Stats::Base" do
      expect(Stats::Base).to receive(:execute_descendants).once.with(atts[:transaction_id], "test_action")
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
      allow(Stats::Sale).to receive(:perform_later).once
      base.perform_now(atts)
      atts2 = atts.merge(type: "credit", device_created_at: atts[:device_created_at])
      base.perform_now(atts2)
    end
  end
end
