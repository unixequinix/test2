require "rails_helper"

RSpec.describe Jobs::Credential::GtagChecker, type: :job do
  let(:event) { create(:event) }
  let(:ticket) { create(:ticket, code: "TICKET_CODE", event: event) }
  let(:gtag) { create(:gtag, tag_uid: "UID1AT20160321130133", event: event) }
  let(:profile) { create(:customer_event_profile, event: event) }
  let(:transaction) do
    create(:credential_transaction, event: event, ticket: ticket, customer_event_profile: profile)
  end
  let(:worker) { Jobs::Credential::GtagChecker.new }
  let(:atts) do
    {
      transaction_id: transaction.id,
      event_id: event.id,
      transaction_origin: "device",
      transaction_category: "credential",
      transaction_type: "ticket_checkin",
      customer_tag_uid: "UID1AT20160321130133",
      operator_tag_uid: "A54DSF8SD3JS0",
      station_id: rand(100),
      device_uid: "2A:35:34:54",
      device_db_index: rand(100),
      device_created_at: "2016-02-05 11:13:39 +0100",
      ticket_code: "TICKET_CODE",
      customer_event_profile_id: profile.id,
      status_code: 0,
      status_message: "All OK"
    }
  end

  describe "actions include" do
    after  { worker.perform(atts) }
    before { allow(Profile::Checker).to receive(:for_transaction).and_return(profile.id) }

    it "assigns a gtag" do
      expect(worker).to receive(:assign_gtag).with(transaction, atts).and_return(gtag)
    end

    it "assigns a ticket credential" do
      expect(worker).to receive(:assign_gtag_credential)
    end

    it "marks redeemed" do
      expect(worker).to receive(:mark_redeemed)
    end
  end
end
