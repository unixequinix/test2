require "spec_helper"

RSpec.describe TicketType, type: :model do
  let(:event) { create(:event) }
  subject { create(:ticket_type, event: event) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  it "touches tickets on update" do
    tickets = create_list(:ticket, 10, event: event, ticket_type: subject)
    subject.update!(name: "name")
    tickets.each { |t| expect(t.reload.updated_at).to eql(subject.updated_at) }
  end
end
