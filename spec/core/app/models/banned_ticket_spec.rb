require "rails_helper"

RSpec.describe BannedTicket, type: :model do
  let(:banned_ticket) { build(:banned_ticket) }

  it "is expected to be valid" do
    expect(banned_ticket).to be_valid
  end
end
