require "rails_helper"

RSpec.describe Operations::Base, type: :job do
  let(:base)  { Operations::Base }
  let(:event) { create(:event) }
  let(:gtag)  { create(:gtag, tag_uid: "AAAAA") }
  let(:params) do
    {
      transaction_category: "credit",
      transaction_type: "sale",
      credits: 30,
      event_id: event.id,
      device_created_at: Time.now.to_s,
      customer_tag_uid: gtag.tag_uid
    }
  end
  let(:real_params) do
    {
      customer_tag_uid: gtag.tag_uid,
      device_created_at: Time.now.to_s,
      transaction_category: "credit",
      transaction_type: "sale",
      device_uid: "5C0A5BA2CF43",
      event_id: event.id,
      sale_items_attributes: [
        {
          product_id: 4,
          quantity: 1.0,
          unit_price: 8.31
        },
        {
          product_id: 5,
          quantity: 1.0,
          unit_price: 2.72
        }
      ],
      credits: -11.030001,
      final_balance: 106.950005,
      final_refundable_balance: 106.950005,
      credits_refundable: -11.030001,
      credit_value: 1.0
    }
  end

  before(:each) do
    # make 100% sure they are loaded into memory, inspect ofr rubocop
    Operations::Credential::TicketChecker.inspect
    Operations::Credential::GtagChecker.inspect
    Operations::Credit::BalanceUpdater.inspect
    Operations::Order::CredentialAssigner.inspect
    # Dont care about the BalanceUpdater or Porfile::Checker, so I mock the behaviour
    allow(Operations::Credit::BalanceUpdater).to receive(:perform_later)
  end

  it "saves sale_items for real params" do
    expect do
      base.write(real_params)
    end.to change(SaleItem, :count).by(real_params[:sale_items_attributes].size)
  end

  it "creates transactions based on transaction_category" do
    obj = base.write(params.merge(status_code: rand(1000)))
    expect(obj.errors.full_messages).to be_empty
  end

  it "executes the job defined by transaction_type" do
    expect(Operations::Credit::BalanceUpdater).to receive(:perform_later).once.with(params)
    base.write(params)
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
      obj = base.write(params.merge(foo: "not valid"))
      expect(obj).not_to be_new_record
    end

    it "works even if jobs fail" do
      allow(Operations::Credit::BalanceUpdater).to receive(:perform_later).and_raise("Error_1")
      expect { base.write(params) }.to raise_error("Error_1")
      params.delete(:transaction_id)
      params.delete(:customer_event_profile_id)
      params.delete(:device_created_at)
      expect(CreditTransaction.where(params)).not_to be_empty
    end
  end

  context "executing subscriptors" do
    it "should only execute subscriptors if the transaction created is new" do
      expect(Operations::Credit::BalanceUpdater).to receive(:perform_later).once
      transaction = base.write(params)
      at = transaction.attributes.symbolize_keys!
      at = at.merge(transaction_category: "credit", device_created_at: params[:device_created_at])
      base.write(at)
    end
  end
end
