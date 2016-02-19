require "rails_helper"

RSpec.describe Jobs::Accreditator, type: :job do
  let(:event) { create(:event) }
  let(:ticket) { build(:ticket) }
  let(:transaction) { create(:credential_transaction, event: event, ticket: ticket) }
  let(:worker) { Jobs::TicketChecker }

  before :each do
    allow(CredentialTransaction).to receive(:find).with(transaction.id).and_return(transaction)
    worker.perform_later(transaction.id)
  end

  it "creates a customer event profile" do
    expect(transaction.customer_event_profile).not_to be_nil
  end

  it "creates a credential assignment for its gtag" do
    gtag = event.gtags.find_by(tag_uid: transaction.customer_tag_uid)
    expect(gtag.credential_assignments).not_to be_empty
  end
end
