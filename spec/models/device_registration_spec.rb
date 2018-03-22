require "rails_helper"

RSpec.describe DeviceRegistration, type: :model do
  let(:event) { create(:event) }
  let(:device) { create(:device) }
  subject { create(:device_registration, event: event, device: device) }

  it "should be valid" do
    expect(subject).to be_valid
  end
end
