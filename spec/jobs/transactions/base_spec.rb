require "spec_helper"

RSpec.describe Transactions::Base, type: :job do
  let(:base)  { Transactions::Base }
  let(:event) { create(:event) }
  let(:gtag)  { create(:gtag, tag_uid: "AAAAA") }
  let(:customer) { create(:customer, event: event) }
  let(:params) do
    {
      type: "credit",
      action: "sale",
      credits: 30,
      event_id: event.id,
      device_created_at: Time.zone.now.to_s,
      customer_tag_uid: gtag.tag_uid,
      status_code: 0
    }
  end

  before(:each) do
    # Dont care about the BalanceUpdater, so I mock the behaviour
    allow(Transactions::Credit::BalanceUpdater).to receive(:perform_now)
  end

  it "creates transactions based on type" do
    expect { base.perform_now(params) }.to change(CreditTransaction, :count).by(1)
  end

  describe "when sale_items_attributes is blank" do
    after do
      expect { base.perform_now(params) }.to change(Transaction, :count).by(1)
    end

    it "works when status code is error (other than 0)" do
      params[:status_code] = 2
    end

    it "removes sale_item_attributes when empty" do
      params[:sale_item_attributes] = []
    end

    it "removes sale_item_attributes when nil" do
      params[:sale_item_attributes] = nil
    end
  end

  describe "when passed sale_items in attributes" do
    before do
      params.merge!(sale_items_attributes: [{ product_id: create(:product).id, quantity: 1.0, unit_price: 8.31 },
                                            { product_id: create(:product).id, quantity: 1.0, unit_price: 2.72 }])
    end

    it "saves sale_items" do
      expect { base.perform_now(params) }.to change(SaleItem, :count).by(2)
    end
  end

  context "when tag_uid is present in DB" do
    before { params[:customer_tag_uid] = gtag.tag_uid }

    it "creates a Gtag if not present in event" do
      expect { base.perform_now(params) }.to change(Gtag, :count).by(1)
    end

    it "does not create a Gtag if present in event" do
      event.gtags << gtag
      expect { base.perform_now(params) }.not_to change(Gtag, :count)
    end
  end

  context "when tag_uid is not present in DB" do
    before { params[:customer_tag_uid] = "1234567890" }

    it "creates a Gtag for the event" do
      expect { base.perform_now(params) }.to change(Gtag, :count).by(1)
    end
  end

  it "executes the job defined by action" do
    params[:action] = "sale"
    expect(Transactions::Credit::BalanceUpdater).to receive(:perform_later).once.with(hash_including(params))
    base.perform_now(params)
  end

  describe "descendants" do
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
          base.perform_now(params.merge(foo: "not valid"))
        end.to change(CreditTransaction, :count).by(1)
      end

      it "works even if jobs fail" do
        params[:action] = "sale"
        allow(Transactions::Credit::BalanceUpdater).to receive(:perform_later).and_raise("Error_1")
        expect { base.perform_now(params) }.to raise_error("Error_1")
        params.delete(:transaction_id)
        params.delete(:customer_id)
        params.delete(:device_created_at)
        expect(CreditTransaction.where(params)).not_to be_empty
      end
    end
  end

  context "executing subscriptors" do
    it "should only execute subscriptors if the transaction created is new" do
      params[:action] = "sale"
      expect(Transactions::Credit::BalanceUpdater).to receive(:perform_later).once
      base.perform_now(params)
      at = params.merge(type: "credit", device_created_at: params[:device_created_at])
      base.perform_now(at)
    end
  end
end
