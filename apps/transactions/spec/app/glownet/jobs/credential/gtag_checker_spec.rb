require "spec_helper"

RSpec.describe Jobs::Credential::GtagChecker, type: :job do
  let(:event) { create(:event) }
  let(:transaction) { create(:credential_transaction, event: event) }
  let(:worker) { Jobs::Credential::GtagChecker }
  let(:atts) do
    {
      event_id: event.id,
      transaction_id: transaction.id,
      customer_tag_uid: transaction.customer_tag_uid
    }
  end

  before :each do
    worker.perform_later(atts)
  end

  it "marks gtag as redeemed" do
    gtag = event.gtags.find_by(tag_uid: transaction.customer_tag_uid)
    expect(gtag).to be_credential_redeemed
  end
end
