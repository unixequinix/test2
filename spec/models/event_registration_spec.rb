require "rails_helper"

RSpec.describe EventRegistration, type: :model do
  let(:event) { create(:event) }
  let(:user) { create(:user) }
  let(:event_registration) { create(:event_registration, event: event) }

  it "can be promoter" do
    event_registration.role = :promoter
    expect(event_registration).to be_promoter
  end

  it "can be support" do
    event_registration.role = :support
    expect(event_registration).to be_support
  end

  it "cannot have more than one user per event" do
    event_registration.update(user: user)
    new_event_registration = event.event_registrations.new(user: user)
    expect(new_event_registration).not_to be_valid
    expect(new_event_registration.errors[:user_id]).not_to be_empty
  end
end
