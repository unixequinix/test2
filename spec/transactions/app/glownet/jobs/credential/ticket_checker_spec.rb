require "rails_helper"

RSpec.describe Jobs::Credential::TicketChecker, type: :job do
  let(:event) { create(:event) }
  let(:ticket) { create(:ticket, code: "TICKET_CODE", event: event) }
  let(:transaction) { create(:credential_transaction, event: event, ticket: ticket) }
  let(:worker) { Jobs::Credential::TicketChecker }
  let(:atts) do
    {
      ticket_code: "TICKET_CODE",
      event_id: event.id,
      transaction_id: transaction.id,
      customer_tag_uid: transaction.customer_tag_uid
    }
  end

  it "marks ticket redeemed" do
    worker.perform_later(atts)
    # because change happens in the DB, to another instance. We have to reload the object.
    transaction.reload
    expect(transaction.ticket).to be_credential_redeemed
  end

  it "works for real params" do
    params = {
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
      customer_event_profile_id: 57_700,
      status_code: 0,
      status_message: "All OK"
    }

    expect { Jobs::Credential::TicketChecker.new.perform(params) }.not_to raise_error
  end
end
