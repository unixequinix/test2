require "spec_helper"

RSpec.describe Transactions::Credential::GtagChecker, type: :job do
  let(:event) { create(:event) }
  let(:gtag) { create(:gtag, tag_uid: "UID1AT20160321130133", event: event) }
  let(:customer) { create(:customer, event: event) }
  let(:worker) { Transactions::Credential::GtagChecker.new }
  let(:atts) do
    {
      event_id: event.id,
      transaction_origin: Transaction::ORIGINS[:device],
      type: "credential",
      action: "ticket_checkin",
      customer_tag_uid: gtag.tag_uid,
      operator_tag_uid: "A54DSF8SD3JS0",
      station_id: rand(100),
      device_uid: "2A:35:34:54",
      device_db_index: rand(100),
      device_created_at: "2016-02-05 11:13:39 +0100",
      ticket_code: "TICKET_CODE",
      customer_id: customer.id,
      status_code: 0,
      status_message: "All OK"
    }
  end

  describe "actions include" do
    after  { worker.perform(atts) }

    it "assigns a ticket credential" do
      expect(worker).to receive(:assign_customer)
    end
  end
end
