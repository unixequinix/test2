require "spec_helper"

RSpec.describe Jobs::Credential::GtagChecker, type: :job do
  let(:event) { create(:event) }
  let(:transaction) { create(:credential_transaction, event: event) }
  let(:worker) { Jobs::Credential::GtagChecker }
  let(:atts) do
    {
      ticket_code: "TICKET_CODE",
      event_id: event.id,
      transaction_id: transaction.id,
      customer_tag_uid: transaction.customer_tag_uid
    }
  end

  before :each do
    allow(CredentialTransaction).to receive(:find).and_return(transaction)
    worker.perform_later(atts)
    transaction.reload
  end

  describe "customer event profile" do
    it "creates one" do
      expect(transaction.customer_event_profile).not_to be_nil
    end

    it "creates a credential assignment for it" do
      expect(transaction.customer_event_profile.credential_assignments).not_to be_empty
    end
  end

  describe "gtag" do
    it "marks redeemed" do
      gtag = event.gtags.find_by(tag_uid: transaction.customer_tag_uid)
      expect(gtag).to be_credential_redeemed
    end
  end
end
