# == Schema Information
#
# Table name: devices
#
#  asset_tracker :string
#  created_at    :datetime         not null
#  device_model  :string
#  imei          :string
#  mac           :string
#  serial_number :string
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_devices_on_mac_and_imei_and_serial_number  (mac,imei,serial_number) UNIQUE
#

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
