require "spec_helper"

RSpec.describe Jobs::Base, type: :job do
  let(:base) { Jobs::Base }
  let(:params) { { transaction_category: "credit", transaction_type: "sale", credits: 30 } }

  it "creates transactions based on transaction_category" do
    number = rand(1000)
    p = params.merge(status_code: number)
    obj = base.write(p)
    expect(obj.errors.full_messages).to be_empty
  end

  it "executes the job defined by transaction_type" do
    expect(Jobs::Credit::BalanceUpdater).to receive(:perform_later)
    base.write(params)
  end

  context "creating transactions" do
    it "ignores attributes not present in table" do
      p = params.merge(foo: "not valid")
      obj = base.write(p)
      expect(obj.errors.full_messages).to be_empty
    end

    it "works even if jobs fail" do
      Jobs::Credential::TicketChecker.inspect # making sure it is loaded into object space
      params = { transaction_category: "credential",
                 transaction_type: "ticket_checkin",
                 status_code: "test code" }
      expect { base.write(params) }.to raise_error
      params.delete(:transaction_category)
      expect(CredentialTransaction.where(params)).not_to be_empty
    end
  end
end
