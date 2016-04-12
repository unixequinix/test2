require "rails_helper"

RSpec.describe Jobs::Base, type: :job do
  let(:base) { Jobs::Base }
  let(:event) { create(:event) }
  let(:params) do
    { transaction_category: "credit", transaction_type: "sale", credits: 30, event_id: event.id }
  end

  before(:each) do
    # make 100% sure they are loaded into memory, inspect ofr rubocop
    Jobs::Credential::TicketChecker.inspect
    Jobs::Credential::GtagChecker.inspect
    Jobs::Credit::BalanceUpdater.inspect
    Jobs::Order::CredentialAssigner.inspect
    # Dont care about the BalanceUpdater or Porfile::Checker, so I mock the behaviour
    allow(Jobs::Credit::BalanceUpdater).to receive(:perform_later)
  end

  it "creates transactions based on transaction_category" do
    number = rand(1000)
    p = params.merge(status_code: number)
    obj = base.write(p)
    expect(obj.errors.full_messages).to be_empty
  end

  it "executes the job defined by transaction_type" do
    expect(Jobs::Credit::BalanceUpdater).to receive(:perform_later).once.with(params)
    base.write(params)
  end

  describe "descendants" do
    it "must be loaded with environment" do
      expect(base.descendants).not_to be_empty
    end

    it "do not include Base clases" do
      expect(base.descendants).not_to include(Jobs::Credential::Base)
    end

    it "should include the descendants of base classes" do
      expect(base.descendants).to include(Jobs::Credential::TicketChecker)
      expect(base.descendants).to include(Jobs::Credential::GtagChecker)
      expect(base.descendants).to include(Jobs::Credit::BalanceUpdater)
      expect(base.descendants).to include(Jobs::Order::CredentialAssigner)
    end
  end

  context "creating transactions" do
    it "ignores attributes not present in table" do
      obj = base.write(params.merge(foo: "not valid"))
      expect(obj).not_to be_new_record
    end

    it "works even if jobs fail" do
      allow(Jobs::Credit::BalanceUpdater).to receive(:perform_later).and_raise(Exception)
      expect { base.write(params) }.to raise_error
      params.delete(:transaction_id)
      params.delete(:customer_event_profile_id)
      expect(CreditTransaction.where(params)).not_to be_empty
    end
  end

  context "executing subscriptors" do
    it "should only execute subscriptors if the transaction created is new" do
      expect(Jobs::Credit::BalanceUpdater).to receive(:perform_later).once
      transaction = base.write(params)
      atts = transaction.attributes
      base.write(atts.symbolize_keys!.merge(transaction_category: "credit"))
    end
  end
end
