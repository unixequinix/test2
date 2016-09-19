require "rails_helper"

RSpec.describe Event::Validator, type: :domain_logic do
  let(:event) { create(:event) }
  subject { Event::Validator.new(event) }

  describe ".check_ticket_types" do
    context "when company ticket types doesnt have a credential type" do
      before { event.company_ticket_types.create(name: "VIP Ticket", company_code: 12, credential_type: nil) }

      it "returns a company_ticket_types array" do
        subject.check_ticket_types
        expect(subject.errors).not_to be_empty
      end
    end

    context "when company ticket types doesnt have a company code" do
      before { event.company_ticket_types.create(name: "VIP Ticket", company_code: nil) }

      it "returns a company_ticket_types array" do
        subject.check_ticket_types
        expect(subject.errors).not_to be_empty
      end
    end
  end

  describe ".check_topups" do
    before { event.update!(features: 1) }

    context "when topups is active but there's not payment services" do
      it "returns a edit_event array" do
        subject.check_topups
        expect(subject.errors).not_to be_empty
      end
    end
  end

  describe ".check_refunds" do
    before { event.update!(features: 2) }

    context "when refund_services is active but there's not refund services" do
      it "returns a edit_event array" do
        subject.check_refunds
        expect(subject.errors).not_to be_empty
      end
    end
  end

  describe ".all" do
    before do
      event.update!(features: 1)
      event.company_ticket_types.create(name: "VIP Ticket", company_code: 10)
    end

    it "returns all errors" do
      subject.all
      expect(subject.errors).not_to be_empty
      expect(subject.errors.size).to eq(2)
    end
  end
end
