require "rails_helper"

RSpec.describe TicketType, type: :model do
  let(:event) { create(:event) }
  subject { create(:ticket_type, event: event) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  it "touches tickets on update" do
    ticket = create(:ticket, event: event, ticket_type: subject)
    updated_at = ticket.updated_at
    subject.update!(name: "name")
    expect(ticket.reload.updated_at).not_to eql(updated_at)
  end
end
