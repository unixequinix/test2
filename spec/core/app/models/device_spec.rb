require "rails_helper"

RSpec.describe Device, type: :model do
  let(:device) { build(:device) }

  it "is expected to be valid" do
    expect(device).to be_valid
  end
end
