require "rails_helper"

RSpec.describe Transactions::Credential::TicketChecker, type: :job do
  let(:event) { create(:event) }
  let(:ticket_code) { "TE469A2F95B47623C" }
  let(:ticket) { create(:ticket, code: "TICKETCODE", event: event) }
  let(:gtag) { create(:gtag, tag_uid: "BBBBBBBBBBBBBB", event: event) }
  let(:transaction) { create(:credential_transaction, event: event, ticket_code: ticket.code, gtag: gtag) }
  let(:worker) { Transactions::Credential::TicketChecker.new }
  let(:decoder) { SonarDecoder }
  let(:ctt_id) { "99" }
  let(:atts) { { transaction_id: transaction.id } }

  it "assigns a ticket to the transaction if its found" do
    expect { worker.perform(atts) }.to change { transaction.reload.ticket }.from(nil).to(ticket)
  end

  it "marks ticket redeemed" do
    expect { worker.perform(atts) }.to change { ticket.reload.redeemed? }.from(false).to(true)
  end

  it "propagates alert if ticket is already redeemed" do
    ticket.update(redeemed: true)
    expect(Alert).to receive(:propagate).once
    worker.perform(atts)
  end

  it "raises error if ticket is neither found nor decoded" do
    transaction.update ticket_code: "NOT_VALID_CODE"
    expect { worker.perform(atts) }.to raise_error(RuntimeError)
  end

  describe ".decode_ticket" do
    before do
      @ctt = create(:ticket_type, event: event, company_code: ctt_id)
      @decoded_ticket = build(:ticket, event: event, code: ticket_code, ticket_type: @ctt)
      allow(SonarDecoder).to receive(:perform).and_return(ctt_id)
      transaction.update ticket_code: ticket_code
    end

    it "calls decode_ticket before not finding" do
      expect(worker).to receive(:decode_ticket).once.and_return(@decoded_ticket)
      worker.perform(atts)
    end

    it "assigns a ticket to the transaction if its decoded" do
      @decoded_ticket.save!
      expect { worker.perform(atts) }.to change { transaction.reload.ticket }.from(nil).to(@decoded_ticket)
    end

    it "attaches the correct ticket_type based on ticket_code" do
      expect(worker.decode_ticket(ticket_code, event).ticket_type).to eq(@ctt)
    end

    it "creates a ticket for the event" do
      expect { worker.decode_ticket(ticket_code, event) }.to change(Ticket, :count).by(1)
    end
  end
end
