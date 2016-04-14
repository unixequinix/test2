require "rails_helper"

RSpec.describe BannedCustomerEventProfile, type: :model do
  let(:banned_customer_event_profile) { build(:banned_customer_event_profile) }

  it "is expected to be valid" do
    expect(banned_customer_event_profile).to be_valid
  end
end
