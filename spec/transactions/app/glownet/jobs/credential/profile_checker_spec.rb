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

  # if id sent, check that tag_uid it matches one gtag of the profile

  # if nil , check tag_uid is associated to profile, if true
  # assign profile_id to transactions
  # else
  # create profile and assign
end
