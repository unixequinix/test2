require "spec_helper"

RSpec.describe Device, type: :model do
  let(:device) { build(:device) }

  it "has a valid factory" do
    expect(device).to be_valid
  end

  describe ".upcase_asset_tracker!" do
    before { device.save }
    it "upcases the asset_tracker" do
      device.update!(asset_tracker: "a12")
      expect(device.asset_tracker).to eq("a12".upcase)
    end
  end
end
