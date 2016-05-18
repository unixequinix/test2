require "rails_helper"

RSpec.describe Operations::Base, type: :job do
  let(:base)  { Operations::Base }
  let(:event) { create(:event) }
  let(:gtag)  { create(:gtag, tag_uid: "AAAAA") }
  let(:params) do
    {
      transaction_category: "credit",
      transaction_type: "nothing",
      credits: 30,
      event_id: event.id,
      device_created_at: Time.zone.now.to_s,
      customer_tag_uid: gtag.tag_uid,
      status_code: 0
    }
  end

  before(:each) do
    # make 100% sure they are loaded into memory
    # inspect caled for rubocops sake
    Operations::Credential::TicketChecker.inspect
    Operations::Credential::GtagChecker.inspect
    Operations::Credit::BalanceUpdater.inspect
    Operations::Order::CredentialAssigner.inspect
    # Dont care about the BalanceUpdater or Porfile::Checker, so I mock the behaviour
    allow(Operations::Credit::BalanceUpdater).to receive(:perform_now)
  end

  it "checks the profile" do
    expect(Profile::Checker).to receive(:for_transaction).once
    base.perform_now(params)
  end

  it "creates transactions based on transaction_category" do
    obj = base.perform_now(params)
    expect(obj.errors.full_messages).to be_empty
  end

  describe "when sale_items_attributes is blank" do
    before do
      atts = hash_not_including(:sale_item_attributes)
      value = CreditTransaction.new
      expect(CreditTransaction).to receive(:create!).with(atts).and_return(value)
    end

    after { base.perform_now(params) }

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
      params.merge!(sale_items_attributes: [{ product_id: 4, quantity: 1.0, unit_price: 8.31 },
                                            { product_id: 5, quantity: 1.0, unit_price: 2.72 }])
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
    before { params[:customer_tag_uid] = "NOT_IN_DB" }

    it "creates a Gtag for the event" do
      expect { base.perform_now(params) }.to change(Gtag, :count).by(1)
    end
  end

  it "executes the job defined by transaction_type" do
    params[:transaction_type] = "sale"
    expect(Operations::Credit::BalanceUpdater).to receive(:perform_later).once.with(params)
    base.perform_now(params)
  end

  describe "descendants" do
    it "must be loaded with environment" do
      expect(base.descendants).not_to be_empty
    end

    it "do not include Base clases" do
      expect(base.descendants).not_to include(Operations::Credential::Base)
    end

    it "should include the descendants of base classes" do
      expect(base.descendants).to include(Operations::Credential::TicketChecker)
      expect(base.descendants).to include(Operations::Credential::GtagChecker)
      expect(base.descendants).to include(Operations::Credit::BalanceUpdater)
      expect(base.descendants).to include(Operations::Order::CredentialAssigner)
    end
  end

  context "creating transactions" do
    it "ignores attributes not present in table" do
      obj = base.perform_now(params.merge(foo: "not valid"))
      expect(obj).not_to be_new_record
    end

    it "passes the correct profile_id" do
      allow(Profile::Checker).to receive(:for_transaction).and_return(5)
      args = hash_including(profile_id: 5)
      expect(CreditTransaction).to receive(:create!).with(args).and_return(CreditTransaction.new)
      base.perform_now(params)
    end

    it "works even if jobs fail" do
      params[:transaction_type] = "sale"
      allow(Operations::Credit::BalanceUpdater).to receive(:perform_later).and_raise("Error_1")
      expect { base.perform_now(params) }.to raise_error("Error_1")
      params.delete(:transaction_id)
      params.delete(:profile_id)
      params.delete(:device_created_at)
      expect(CreditTransaction.where(params)).not_to be_empty
    end
  end

  context "executing subscriptors" do
    it "should only execute subscriptors if the transaction created is new" do
      params[:transaction_type] = "sale"
      expect(Operations::Credit::BalanceUpdater).to receive(:perform_later).once
      transaction = base.perform_now(params)
      at = transaction.attributes.symbolize_keys!
      at = at.merge(transaction_category: "credit", device_created_at: params[:device_created_at])
      base.perform_now(at)
    end
  end
end
