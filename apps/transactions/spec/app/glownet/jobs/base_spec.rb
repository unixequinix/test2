require "spec_helper"

RSpec.describe Jobs::Base, type: :job do
  let(:base) { Jobs::Base }
  let(:params) { { transaction_category: "credit", transaction_type: "sale", credits: 30 } }

  before(:each) do
    # Dont care about the BalanceUpdater, so i mock its behaviour so that it doesnt bother the tests
    allow(Jobs::Credit::BalanceUpdater).to receive(:perform_later)
  end

  it "creates transactions based on transaction_category" do
    number = rand(1000)
    p = params.merge(status_code: number)
    obj = base.write(p)
    expect(obj.errors.full_messages).to be_empty
  end

  it "executes the job defined by transaction_type" do
    base.write(params)
  end

  describe "descendants" do
    it "must be loaded with environment" do
      expect(base.descendants).not_to be_empty
    end

    it "do not include Base clases" do
      Jobs::Credential::Base.inspect # make 100% sure it is loaded into memory
      expect(base.descendants).not_to include(Jobs::Credential::Base)
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
      expect(CreditTransaction.where(params)).not_to be_empty
    end
  end
end
