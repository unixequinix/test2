require "spec_helper"

RSpec.describe Jobs::Credential::TicketChecker, type: :job do
  let(:event) { create(:event) }
  let(:ticket) { create(:ticket, code: "TICKET_CODE") }
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
    expect(transaction.ticket).to be_credential_redeemed
  end
end
