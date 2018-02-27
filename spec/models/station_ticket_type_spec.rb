require 'rails_helper'

RSpec.describe StationTicketType, type: :model do
  let(:event) { create(:event) }
  let(:station) { create(:station, event: event) }
  let(:ticket_type) { create(:ticket_type) }
  subject { station.station_ticket_types.new(ticket_type: ticket_type) }

  it "must update station when created" do
    expect { subject.save! }.to change(station, :updated_at)
  end
end
