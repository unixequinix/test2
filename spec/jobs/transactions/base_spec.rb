require "rails_helper"

RSpec.describe Transactions::Base, type: :job do
  let(:base)  { Transactions::Base }
  let(:event) { create(:event) }
  let(:gtag)  { create(:gtag, tag_uid: "AAAAAAAAAAAAAA", event: event) }
  let(:customer) { create(:customer, event: event) }
  let(:atts) { { type: "CreditTransaction", action: "test_action", credits: 30, event_id: event.id, device_created_at: Time.current.to_s, customer_tag_uid: gtag.tag_uid, status_code: 0 } }

  describe "processing payment data" do
    before(:each) do
      atts[:payments] = [{ "amount" => 10, "credit_id" => event.credit.id, "final_balance" => 5 },
                         { "amount" => 2, "credit_id" => event.virtual_credit.id, "final_balance" => 12 }]
      base.perform_now(atts)
      @t = gtag.transactions.credit.last
    end

    it "makes a hash of payments from an array" do
      result = { event.credit.id.to_s => { "amount" => 10, "final_balance" => 5 },
                 event.virtual_credit.id.to_s => { "amount" => 2, "final_balance" => 12 } }
      expect(@t.payments).to eq(result)
    end

    it "makes a hash of payments from an array" do
      result = { event.credit.id.to_s => { "amount" => 10, "final_balance" => 5 },
                 event.virtual_credit.id.to_s => { "amount" => 2, "final_balance" => 12 } }
      expect(@t.payments).to eq(result)
    end
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
      atts.merge!(sale_items_attributes: [{ product_id: create(:product).id, quantity: 1.0, standard_unit_price: 8.31 },
                                          { product_id: create(:product).id, quantity: 1.0, standard_unit_price: 2.72 }])
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
        allow(Transactions::PostProcessor).to receive(:perform_later).and_raise("Error_1")
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
      expect(Pokes::Sale).to receive(:perform_later).once
      base.perform_now(atts)
      atts2 = atts.merge(type: "CreditTransaction", device_created_at: atts[:device_created_at])
      base.perform_now(atts2)
    end
  end
end
