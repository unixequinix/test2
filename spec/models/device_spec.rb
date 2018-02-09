require "rails_helper"

RSpec.describe Device, type: :model do
  let(:device) { build(:device) }

  it "has a valid factory" do
    expect(device).to be_valid
  end

  it "downcases mac on create" do
    device = Device.create!(mac: "FOO", asset_tracker: "Blah")
    expect(device.mac).to eql("foo")
  end

  it "downcases mac on update" do
    device.update(mac: "FOO")
    expect(device.mac).to eql("foo")
  end

  it "downcases mac on save" do
    device.mac = "FOO"
    device.save
    expect(device.mac).to eql("foo")
  end

  it "works with blank macs" do
    device.update(mac: "")
    expect(device.mac).to eql("")
  end

  it "works with nil macs" do
    device.update(mac: nil)
    expect(device.mac).to eql(nil)
  end
end
