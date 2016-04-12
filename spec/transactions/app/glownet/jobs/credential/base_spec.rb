require "rails_helper"

RSpec.describe Jobs::Credential::Base, type: :job do
  let(:event) { create(:event) }
  let(:transaction) { create(:credential_transaction, event: event) }
  let(:gtag) { create(:gtag, event: event) }
  let(:ticket_code) { "TC8B106BA990BDC56" }
  let(:ticket) { create(:ticket, event: event, credential_redeemed: false, code: ticket_code) }
  let(:profile) { create(:customer_event_profile, event: event) }
  let(:worker) { Jobs::Credential::Base.new }
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

  describe ".assign_gtag" do
    before(:each) { transaction.ticket = ticket }

    it "creates a gtag for the transaction event passed" do
      expect(event.gtags).to be_empty
      expect do
        worker.assign_gtag(transaction, atts)
      end.to change(transaction.event.gtags, :count).by(1)
    end

    it "leaves the gtag if already present" do
      event.gtags.create!(tag_uid: atts[:customer_tag_uid])
      expect do
        worker.assign_gtag(transaction, atts)
      end.not_to change(transaction.event.gtags, :count)
    end
  end

  describe ".assign_gtag_credential" do
    it "creates a credential for the gtag" do
      expect do
        worker.assign_gtag_credential(gtag, profile.id)
      end.to change(gtag, :assigned_gtag_credential)
    end

    it "leaves the current assigned_gtag_credential if one present" do
      gtag.create_assigned_gtag_credential!(customer_event_profile: profile)
      expect do
        worker.assign_gtag_credential(gtag, profile)
      end.not_to change(gtag, :assigned_gtag_credential)
    end
  end

  describe ".assign_ticket" do
    before(:each) do
      @ctt = create(:company_ticket_type, event: event, company_code: ctt_id)
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

    it "attaches the correct company_ticket_type based on ticket_code" do
      allow(TicketDecoder::SonarDecoder).to receive(:perform).and_return(ctt_id)
      worker.assign_ticket(transaction, atts)
      expect(transaction.ticket.company_ticket_type).to eq(@ctt)
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
      end.not_to change(transaction.event.tickets, :count)
    end
  end

  describe ".assign_ticket_credential" do
    it "creates a credential for the ticket" do
      expect do
        worker.assign_ticket_credential(ticket, profile.id)
      end.to change(ticket, :assigned_ticket_credential)
    end

    it "leaves the current assigned_ticket_credential if one present" do
      ticket.create_assigned_ticket_credential!(customer_event_profile: profile)
      expect do
        worker.assign_ticket_credential(ticket, profile)
      end.not_to change(ticket, :assigned_ticket_credential)
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
