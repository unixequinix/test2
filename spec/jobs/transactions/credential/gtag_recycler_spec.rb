require "rails_helper"

RSpec.describe Transactions::Credential::GtagRecycler, type: :job do
  let(:event) { create(:event) }
  let(:gtag) { create(:gtag, tag_uid: "UID1AT20160321130133", event: event) }
  let(:profile) { create(:profile, event: event) }
  let(:worker) { Transactions::Credential::GtagRecycler }
  let(:atts) do
    {
      event_id: event.id,
      transaction_origin: Transaction::ORIGINS[:device],
      transaction_category: "credential",
      transaction_type: "gtag_recycle",
      customer_tag_uid: gtag.tag_uid,
      operator_tag_uid: "A54DSF8SD3JS0",
      station_id: rand(100),
      device_uid: "2A:35:34:54",
      device_db_index: rand(100),
      device_created_at: "2016-02-05 11:13:39 +0100",
      ticket_code: "TICKET_CODE",
      profile_id: profile.id,
      status_code: 0,
      status_message: "OK"
    }
  end

  describe "actions include" do
    before { gtag.credential_assignments.create(profile: profile) }

    it "unassigns the gtag" do
      worker.perform_now(atts)
      expect(profile.active_gtag_assignment).to be_nil
    end
  end
end
