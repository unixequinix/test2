require "rails_helper"

RSpec.describe Jobs::Credential::ProfileChecker, type: :job do
  let(:event) { create(:event) }
  let(:tag_uid) { "SOMETAGUID" }
  let(:ticket) { create(:ticket, code: "TICKET_CODE", event: event) }
  let(:worker) { Jobs::Credential::ProfileChecker.new }
  let(:profile) { create(:customer_event_profile, event: event) }
  let(:gtag) { create(:gtag, tag_uid: tag_uid, event: event) }
  let(:transaction) do
    create(:credential_transaction, event: event, ticket: ticket, customer_tag_uid: tag_uid)
  end
  let(:atts) do
    {
      ticket_code: "TICKET_CODE",
      event_id: event.id,
      transaction_id: transaction.id,
      customer_tag_uid: transaction.customer_tag_uid
    }
  end

  context "with customer_event_profile id" do
    before do
      CredentialAssignment.create(credentiable: gtag, customer_event_profile: profile)
    end

    it "fails if profile is present but does not match any gtag profiles for the event" do
      atts[:customer_event_profile_id] = 9999
      expect { worker.perform(atts) }.to raise_error(RuntimeError, /Mismatch/)
    end
  end
end
