require "rails_helper"

RSpec.describe Jobs::Monetary::BalanceIncreaser, type: :job do
  let(:event) { create(:event) }
  let(:ticket) { build(:ticket) }
  let(:transaction) { create(:credential_transaction, event: event, ticket: ticket) }
  let(:worker) { Jobs::Monetary::TicketChecker }

  before :each do
    allow(CredentialTransaction).to receive(:find).with(transaction.id).and_return(transaction)
    worker.perform_later(transaction.id)
  end
end
