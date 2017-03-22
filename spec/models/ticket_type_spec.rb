require "spec_helper"

RSpec.describe TicketType, type: :model do
  subject { build(:ticket_type) }
  let(:event) { create(:event) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end
end
