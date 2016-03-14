require "spec_helper"

RSpec.describe Jobs::Credential::Base, type: :job do
  let(:event) { create(:event) }
  let(:transaction) { create(:credential_transaction, event: event) }
  let(:gtag) { create(:gtag, event: event) }
  let(:ticket) { create(:ticket, event: event, credential_redeemed: false) }
  let(:profile) { create(:customer_event_profile, event: event) }
  let(:worker) { Jobs::Credential::Base.new }
  let(:atts) do
    {
      event_id: event.id,
      transaction_id: transaction.id,
      customer_tag_uid: transaction.customer_tag_uid
    }
  end

  describe ".assign_profile" do
    it "creates a profile for the transaction passed" do
      expect do
        worker.assign_profile(transaction, atts)
      end.to change(transaction, :customer_event_profile)
    end

    it "leaves the profile if already present" do
      transaction.create_customer_event_profile!(event: event)
      expect do
        worker.assign_profile(transaction, atts)
      end.not_to change(transaction, :customer_event_profile)
    end
  end

  describe ".assign_gtag" do
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
        worker.assign_gtag_credential(gtag, profile)
      end.to change(gtag, :assigned_gtag_credential)
    end

    it "leaves the current assigned_gtag_credential if one present" do
      gtag.create_assigned_gtag_credential!(customer_event_profile: profile)
      expect do
        worker.assign_gtag_credential(gtag, profile)
      end.not_to change(gtag, :assigned_gtag_credential)
    end
  end

  describe ".assign_ticket_credential" do
    it "creates a credential for the ticket" do
      expect do
        worker.assign_ticket_credential(ticket, profile)
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
