require "rails_helper"

RSpec.describe Device, type: :model do
  let(:device) { create(:device) }

  it "has a valid factory" do
    expect(device).to be_valid
  end

  describe "within the same team" do
    let(:team) { create(:team) }
    before { device.update! team: team }

    it "should not allow to create device with same asset_tracker" do
      device.update(asset_tracker: 'device')
      device2 = build(:device, asset_tracker: device.asset_tracker, team: team)
      expect(device2).not_to be_valid
    end

    it "should not allow to create device with similar asset_tracker" do
      device.update(asset_tracker: 'device')
      device2 = build(:device, asset_tracker: 'Device', team: team)
      expect(device2).not_to be_valid
    end

    it "should not allow to create device with same mac" do
      device2 = build(:device, mac: device.mac, team: team)
      expect(device2).not_to be_valid
    end
  end

  describe "with different teams" do
    let(:team) { create(:team) }
    let(:team2) { create(:team) }
    before { device.update! team: team }

    it "should not allow to create device with same asset_tracker" do
      device.update(asset_tracker: 'device')
      device2 = build(:device, asset_tracker: device.asset_tracker, team: team2)
      expect(device2).to be_valid
    end

    it "should not allow to create device with similar asset_tracker" do
      device.update(asset_tracker: 'device')
      device2 = build(:device, asset_tracker: 'Device', team: team2)
      expect(device2).to be_valid
    end

    it "should not allow to create device with same mac" do
      device2 = build(:device, mac: device.mac, team: team2)
      expect(device2).to be_valid
    end
  end
end
