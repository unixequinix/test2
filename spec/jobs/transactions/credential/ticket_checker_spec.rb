require "rails_helper"

RSpec.describe Transactions::Credential::TicketChecker, type: :job do
  let(:event) { create(:event) }
  let(:ticket) { create(:ticket, event: event) }
  let(:transaction) { create(:credential_transaction, event: event, ticket: ticket) }
  let(:worker) { Transactions::Credential::TicketChecker.new }
  let(:atts) { { transaction_id: transaction.id } }

  it "marks ticket redeemed" do
    expect { worker.perform(atts) }.to change { ticket.reload.redeemed? }.from(false).to(true)
  end

  it "propagates alert if ticket is already redeemed" do
    ticket.update(redeemed: true)
    expect(Alert).to receive(:propagate).once
    worker.perform(atts)
  end
end
