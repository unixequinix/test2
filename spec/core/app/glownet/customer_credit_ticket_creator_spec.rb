require "rails_helper"

RSpec.describe CustomerCreditTicketCreator, type: :domain_logic do
  let(:ticket) { create(:ticket, :with_purchaser, :assigned) }
  let(:profile) { ticket.assigned_profile }
  let(:credit) { Sorters::FakeCatalogItem.new(value: 10, total_amount: 10) }
  before { allow(ticket).to receive(:credits).and_return([credit]) }

  subject { CustomerCreditTicketCreator.new }

  context "when assigning" do
    it "creates a customer credit for every ticket credit" do
      expect(subject).to receive(:create_credit).exactly(ticket.credits.count).times
      subject.assign(ticket)
    end
  end

  context ".assign" do
    it "loops through the ticket credits" do
      origin = CustomerCredit::TICKET_ASSIGNMENT
      expect(subject).to receive(:loop_credits).once.with(ticket, origin, 1)
      subject.assign(ticket)
    end
  end

  context ".unassign" do
    it "loops through the ticket credits with negative values" do
      origin = CustomerCredit::TICKET_UNASSIGNMENT
      expect(subject).to receive(:loop_credits).once.with(ticket, origin, -1)
      subject.unassign(ticket)
    end
  end

  describe ".loop_credits" do
    it "sends orders to create a customer credit for every ticket credit" do
      expect(subject).to receive(:create_credit).exactly(ticket.credits.count).times
      subject.loop_credits(ticket, "origin")
    end

    it "sets the amount to negative if told so" do
      expect(subject).to receive(:create_credit).with(profile, hash_including(amount: -10))
      subject.loop_credits(ticket, "origin", -1)
    end

    it "sets credit value to that one of credit" do
      expect(subject).to receive(:create_credit).with(profile, hash_including(credit_value: 10))
      subject.loop_credits(ticket, "origin")
    end

    it "sets origin to that of argument" do
      origin = "somethingweird"
      atts = hash_including(transaction_origin: origin)
      expect(subject).to receive(:create_credit).with(profile, atts)
      subject.loop_credits(ticket, origin)
    end
  end
end
