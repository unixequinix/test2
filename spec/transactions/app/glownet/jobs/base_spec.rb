require "rails_helper"

RSpec.describe Jobs::Base, type: :job do
  let(:base) { Jobs::Base }
  let(:event) { create(:event) }
  let(:params) do
    { transaction_category: "credit", transaction_type: "sale", credits: 30, event_id: event.id }
  end

  before(:each) do
    # Dont care about the BalanceUpdater, so I mock the behaviour
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

  context ".assign_profile" do
    let(:event) { create(:event) }
    let(:tag_uid) { "SOMETAGUID" }
    let(:ticket) { create(:ticket, code: "TICKET_CODE", event: event) }
    let(:worker) { base.new }
    let(:profile) { create(:customer_event_profile, event: event) }
    let(:gtag) { create(:gtag, tag_uid: tag_uid, event: event) }
    subject do
      create(:credential_transaction, event: event, ticket: ticket, customer_tag_uid: tag_uid)
    end
    let(:atts) do
      {
        ticket_code: "TICKET_CODE",
        event_id: event.id,
        transaction_id: subject.id,
        customer_tag_uid: subject.customer_tag_uid
      }
    end

    describe "with customer_event_profile_id" do
      before do
        CredentialAssignment.create(credentiable: gtag, customer_event_profile: profile)
        atts[:customer_event_profile_id] = 9999
      end

      it "fails if it does not match any gtag profiles for the event" do
        expect { worker.assign_profile(subject, atts) }.to raise_error(RuntimeError, /Mismatch/)
      end

      it "does not change a thing if profile matches that of gtag" do
        subject.customer_event_profile = profile
        atts[:customer_event_profile_id] = profile.id
        gtag.assigned_customer_event_profile = profile
        expect do
          worker.assign_profile(subject, atts)
        end.not_to change(subject, :customer_event_profile)
      end
    end

    describe "without customer_event_profile" do
      it "creates a profile for the transaction passed" do
        expect do
          worker.assign_profile(subject, atts)
        end.to change(subject, :customer_event_profile)
      end

      it "assigns that of gtag if present" do
        gtag.assigned_customer_event_profile = profile
        expect { worker.assign_profile(subject, atts) }.to change(subject, :customer_event_profile)
        expect(subject.customer_event_profile).to eq(profile)
      end
    end
  end

  describe "descendants" do
    it "must be loaded with environment" do
      expect(base.descendants).not_to be_empty
    end

    it "do not include Base clases" do
      Jobs::Credential::Base.inspect # make 100% sure it is loaded into memory
      expect(base.descendants).not_to include(Jobs::Credential::Base)
    end

    it "should include the descendants of base classes" do
      # make 100% sure they are loaded into memory
      Jobs::Credential::TicketChecker.inspect
      Jobs::Credential::GtagChecker.inspect
      Jobs::Credit::BalanceUpdater.inspect
      Jobs::Order::CredentialAssigner.inspect
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
