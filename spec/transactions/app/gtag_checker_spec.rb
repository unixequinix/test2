require "rails_helper"

RSpec.describe Jobs::GtagChecker, type: :job do
  let(:event) { create(:event) }
  let(:ticket) { build(:ticket) }
  let(:transaction) { create(:credential_transaction, event: event, ticket: ticket) }
  let(:worker) { Jobs::TicketChecker }

  before :each do
    allow(CredentialTransaction).to receive(:find).with(transaction.id).and_return(transaction)
    worker.perform_later(transaction.id)
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
      expect(gtag).not_to be_credential_redeemed
    end
  end
end
