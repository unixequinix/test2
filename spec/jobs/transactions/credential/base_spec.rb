require "rails_helper"

RSpec.describe Transactions::Credential::Base, type: :job do
  let(:event) { create(:event) }
  let(:transaction) { create(:credential_transaction, event: event) }
  let(:gtag) { create(:gtag, event: event) }
  let(:ticket_code) { "TC8B106BA990BDC56" }
  let(:ticket) { create(:ticket, event: event, credential_redeemed: false, code: ticket_code) }
  let(:profile) { create(:profile, event: event) }
  let(:worker) { Transactions::Credential::Base.new }
  let(:decoder) { TicketDecoder::SonarDecoder }
  let(:ctt_id) { "99" }
  let(:atts) do
    {
      event_id: event.id,
      transaction_id: transaction.id,
      customer_tag_uid: transaction.customer_tag_uid,
      ticket_code: ticket_code
    }
  end

  before { allow(decoder).to receive(:perform).with(ticket_code).and_return(ctt_id) }

  describe ".assign_profile" do
    it "creates a credential for the gtag" do
      expect do
        worker.assign_profile(gtag, profile.id)
      end.to change(gtag, :profile)
    end

    it "leaves the current profile if one present" do
      gtag.update!(profile: profile)
      expect do
        worker.assign_profile(gtag, profile)
      end.not_to change(gtag, :profile)
    end
  end

  describe ".assign_ticket" do
    before(:each) do
      @ctt = create(:company_ticket_type, event: event, company_code: ctt_id)
    end

    context "with sonar decryption" do
      before { allow(TicketDecoder::SonarDecoder).to receive(:perform).and_return(ctt_id) }
      it "attaches the correct company_ticket_type based on ticket_code" do
        ticket = worker.assign_ticket(transaction, atts)
        expect(ticket.company_ticket_type).to eq(@ctt)
      end

      it "attaches the ticket_id to the transaction" do
        worker.assign_ticket(transaction, atts)
        expect(transaction.reload.ticket_id).not_to be_nil
      end
    end

    it "finds the ticket if present" do
      t = create(:ticket, event: event, code: ticket_code)
      expect(decoder).not_to receive(:perform)
      expect(worker.assign_ticket(transaction, atts)).to eq(t)
    end

    it "tries to decode the ticket if not present" do
      expect(decoder).to receive(:perform).and_return(ctt_id)
      worker.assign_ticket(transaction, atts)
    end

    it "raises error if ticket is neither found nor decoded" do
      atts[:ticket_code] = "NOT_VALID_CODE"
      expect { worker.assign_ticket(transaction, atts) }.to raise_error
    end

    it "creates a ticket for the event" do
      expect do
        worker.assign_ticket(transaction, atts)
      end.to change(transaction.event.tickets, :count).by(1)
    end

    it "leaves the ticket if already present" do
      transaction.create_ticket!(event: event, code: ticket_code, company_ticket_type: @ctt)
      expect do
        worker.assign_ticket(transaction, atts)
      end.not_to change(event.tickets, :count)
    end
  end

  describe ".assign_profile_to_ticket" do
    it "creates a credential for the ticket" do
      expect do
        worker.assign_profile_to_ticket(ticket, profile.id)
      end.to change(ticket, :profile)
    end

    it "leaves the current profile if one present" do
      ticket.update(profile: profile)
      expect do
        worker.assign_profile_to_ticket(ticket, profile)
      end.not_to change(ticket, :profile)
    end
  end

  describe ".mark_redeemed" do
    it "marks object as credential_redeemed" do
      expect do
        worker.mark_redeemed(ticket)
      end.to change(ticket, :credential_redeemed)
    end
  end
end
