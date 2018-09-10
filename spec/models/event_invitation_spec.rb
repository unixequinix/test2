require 'rails_helper'

RSpec.describe EventInvitation, type: :model do
  let(:event) { create(:event) }
  let(:event_invitation) { create(:event_invitation, event: event) }

  it "can be promoter" do
    event_invitation.role = :promoter
    expect(event_invitation).to be_promoter
  end

  it "can be support" do
    event_invitation.role = :support
    expect(event_invitation).to be_support
  end

  it "cannot invite without event" do
    event_invitation.update(event: nil)
    expect(event_invitation).not_to be_valid
    expect(event_invitation.errors[:event_id]).not_to be_empty
  end
end
