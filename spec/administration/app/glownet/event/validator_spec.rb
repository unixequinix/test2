require "rails_helper"

RSpec.describe Event::Validator, type: :domain_logic do
  let(:event) { create(:event) }
  subjet { Event::Validator.new(event) }

  describe ".check_ticket_types" do
    before { event.company_ticket_types.create(name: "VIP Ticket", company_code: 10) }

    it "returns an errors hash" do
      expect(subject.check_ticket_types.keys).to eq([:company_ticket_types])
    end
  end
end
