require "spec_helper"

RSpec.describe Transactions::Credential::TicketChecker, type: :job do
  let(:event) { create(:event) }
  let(:ticket) { create(:ticket, code: "TICKET_CODE", event: event) }
  let(:gtag) { create(:gtag, tag_uid: "FFF123FFF", event: event) }
  let(:transaction) { create(:credential_transaction, event: event, ticket: ticket) }
  let(:worker) { Transactions::Credential::TicketChecker.new }
  let(:atts) do
    {
      transaction_id: transaction.id,
      event_id: event.id,
      transaction_category: "credential",
      action: "ticket_checkin",
      customer_tag_uid: gtag.tag_uid,
      ticket_code: "TICKET_CODE",
      status_code: 0
    }
  end

  describe "actions include" do
    after  { worker.perform(atts) }

    it "assigns a ticket" do
      expect(worker).to receive(:assign_ticket).with(transaction, atts).and_return(ticket)
    end

    it "marks redeemed" do
      expect(worker).to receive(:mark_redeemed)
    end
  end
end
