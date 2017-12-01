require "rails_helper"

RSpec.describe Transactions::Credential::TicketChecker, type: :job do
  let(:event) { create(:event) }
  let(:ticket) { create(:ticket, event: event) }
  let(:transaction) { create(:credential_transaction, event: event, ticket: ticket) }
  let(:worker) { Transactions::Credential::TicketChecker.new }

  it "marks ticket redeemed" do
    expect { worker.perform(transaction) }.to change { ticket.reload.redeemed? }.from(false).to(true)
  end

  it "propagates alert if ticket is already redeemed" do
    ticket.update(redeemed: true)
    expect(Alert).to receive(:propagate).once
    worker.perform(transaction)
  end
end
