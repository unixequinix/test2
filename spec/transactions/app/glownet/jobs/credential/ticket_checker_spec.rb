require "rails_helper"

RSpec.describe Jobs::Credential::TicketChecker, type: :job do
  let(:event) { create(:event) }
  let(:ticket) { create(:ticket) }
  let(:transaction) { create(:credential_transaction, event: event, ticket: ticket) }
  let(:worker) { Jobs::Credential::TicketChecker }

  before :each do
    allow(CredentialTransaction).to receive(:find).and_return(transaction)
  end

  describe "error handling" do
    it "should not perform any changes if any error is raised" do
      transaction.update! ticket: nil # force the error
      expect { worker.perform_later(transaction.id) }.to raise_error
      expect(transaction.reload.customer_event_profile).to be_nil
    end
  end

  context "asynchronously" do
    before :each do
      worker.perform_later(transaction.id)
    end

    it "creates a customer event profile" do
      expect(transaction.customer_event_profile).not_to be_nil
    end

    it "creates a credential assignment for the customer event profile" do
      expect(transaction.customer_event_profile.credential_assignments).not_to be_empty
    end

    it "creates a gtag for the event" do
      expect(event.gtags.find_by(tag_uid: transaction.customer_tag_uid)).not_to be_nil
    end

    it "creates a credential assignment for the gtag" do
      gtag = event.gtags.find_by(tag_uid: transaction.customer_tag_uid)
      expect(gtag.credential_assignments).not_to be_empty
    end

    describe "ticket" do
      it "marks ticket redeemed" do
        expect(transaction.ticket).to be_credential_redeemed
      end
    end
  end
end
