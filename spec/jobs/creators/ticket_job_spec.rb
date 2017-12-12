require "rails_helper"

RSpec.describe Creators::TicketJob, type: :job do
  let(:worker) { Creators::TicketJob }
  let(:event) { create(:event) }
  let(:ticket_type) { create(:ticket_type, event: event) }
  let(:ticket) { create(:ticket, event: event, ticket_type: ticket_type) }

  let!(:atts) { { event_id: event.id, code: SecureRandom.hex(4), ticket_type: ticket_type } }
  let!(:old_atts) { { event_id: event.id, code: ticket.code, ticket_type: ticket_type, banned: true } }

  context "creating ticket" do
    it "can create a ticket" do
      expect { worker.perform_now(atts) }.to change { event.tickets.count }.by(1)
    end
    it "can update a ticket" do
      expect { worker.perform_now(old_atts) }.not_to change { event.tickets.count }
    end
  end
end
