require "rails_helper"

RSpec.describe Device, type: :model do
  let(:device) { create(:device) }

  it "has a valid factory" do
    expect(device).to be_valid
  end

  it "should not allow to create device with same app_id" do
    expect(build(:device, app_id: device.app_id)).not_to be_valid
  end

  describe "with different teams" do
    let(:team) { create(:team) }
    let(:team2) { create(:team) }
    before { device.update! team: team }

    it "should not allow to create device with same asset_tracker" do
      device.update(asset_tracker: 'device')
      expect(build(:device, asset_tracker: device.asset_tracker, team: team2)).to be_valid
    end

    it "should not allow to create device with similar asset_tracker" do
      device.update(asset_tracker: 'device')
      expect(build(:device, asset_tracker: 'Device', team: team2)).to be_valid
    end

    it "should not allow to create device with same mac" do
      expect(build(:device, mac: device.mac, team: team2)).to be_valid
    end
  end
end
