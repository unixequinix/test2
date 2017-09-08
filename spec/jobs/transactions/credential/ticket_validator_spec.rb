require "rails_helper"

RSpec.describe Transactions::Credential::TicketValidator, type: :job do
  let(:event) { create(:event) }
  let(:ticket) { create(:ticket, event: event, customer: nil) }
  let(:transaction) { create(:credential_transaction, action: "ticket_validation", event: event, ticket_code: ticket.code) }
  let(:worker) { Transactions::Credential::TicketValidator.new }
  let(:atts) { { transaction_id: transaction.id } }

  describe ".perform" do
    it "redeems the ticket" do
      expect { worker.perform(atts) }.to change { ticket.reload.redeemed }.from(false).to(true)
    end

    it "propagates alert if ticket is already redeemed" do
      ticket.update(redeemed: true)
      expect(Alert).to receive(:propagate).once
      worker.perform(atts)
    end

    it "assigns a customer if ticket does not have one" do
      expect { worker.perform(atts) }.to change { ticket.reload.customer }.from(nil)
    end

    it "leaves the customer alone if already present" do
      customer = create(:customer, event: event)
      ticket.update customer: customer
      expect { worker.perform(atts) }.not_to change { ticket.reload.customer } # rubocop:disable Lint/AmbiguousBlockAssociation
    end
  end
end
