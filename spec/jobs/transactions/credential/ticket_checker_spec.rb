require "spec_helper"

RSpec.describe Transactions::Credential::TicketChecker, type: :job do
  let(:event) { create(:event) }
  let(:ticket_code) { "TC8B106BA990BDC56" }
  let(:ticket) { create(:ticket, code: "TICKETCODE", event: event) }
  let(:gtag) { create(:gtag, tag_uid: "FFF123FFF", event: event) }
  let(:transaction) { create(:credential_transaction, event: event, ticket: ticket) }
  let(:worker) { Transactions::Credential::TicketChecker.new }
  let(:decoder) { SonarDecoder }
  let(:ctt_id) { "99" }
  let(:atts) do
    {
      transaction_id: transaction.id,
      event_id: event.id,
      type: "credential",
      action: "ticket_checkin",
      customer_tag_uid: gtag.tag_uid,
      ticket_code: "TICKETCODE",
      status_code: 0
    }
  end

  describe "actions include" do
    it "assigns a ticket" do
      expect(worker).to receive(:assign_ticket).with(transaction, atts).and_return(ticket)
      worker.perform(atts)
    end

    it "marks redeemed" do
      ticket.update!(redeemed: false)
      worker.perform(atts)
      expect(ticket.reload).to be_redeemed
    end
  end

  describe ".assign_ticket" do
    before { @ctt = create(:ticket_type, event: event, company_code: ctt_id) }

    context "with sonar decryption" do
      before do
        allow(SonarDecoder).to receive(:perform).and_return(ctt_id)
        atts[:ticket_code] = ticket_code
      end

      it "attaches the correct ticket_type based on ticket_code" do
        ticket = worker.assign_ticket(transaction, atts)
        expect(ticket.ticket_type).to eq(@ctt)
      end

      it "attaches the ticket_id to the transaction" do
        worker.assign_ticket(transaction, atts)
        expect(transaction.reload.ticket_id).not_to be_nil
      end

      it "creates a ticket for the event" do
        expect { worker.assign_ticket(transaction, atts) }.to change(Ticket, :count).by(1)
      end
    end

    it "finds the ticket if present" do
      atts[:ticket_code] = ticket_code
      t = create(:ticket, event: event, code: ticket_code)
      expect(decoder).not_to receive(:perform)
      expect(worker.assign_ticket(transaction, atts)).to eq(t)
    end

    it "tries to decode the ticket if not present" do
      atts[:ticket_code] = ticket_code
      expect(decoder).to receive(:perform).and_return(ctt_id)
      worker.assign_ticket(transaction, atts)
    end

    it "raises error if ticket is neither found nor decoded" do
      atts[:ticket_code] = "NOT_VALID_CODE"
      expect { worker.assign_ticket(transaction, atts) }.to raise_error(RuntimeError)
    end

    it "leaves the ticket if already present" do
      transaction.create_ticket!(event: event, code: ticket_code, ticket_type: @ctt)
      expect { worker.assign_ticket(transaction, atts) }.not_to change(Ticket, :count)
    end
  end
end
