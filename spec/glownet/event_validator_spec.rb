require "spec_helper"

RSpec.describe EventValidator, type: :domain_logic do
  let(:event) { create(:event) }
  subject { EventValidator.new(event) }

  describe ".all" do
    context "when company ticket types doesnt have a company code" do
      before { event.ticket_types.create(name: "VIP Ticket", company_code: nil) }

      it "returns a ticket_types array" do
        subject.all
        expect(subject.errors).not_to be_empty
      end
    end
  end
end
