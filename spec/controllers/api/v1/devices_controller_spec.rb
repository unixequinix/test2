require "spec_helper"

RSpec.describe Api::V1::DevicesController, type: :controller do
  let(:admin) { create(:admin) }
  let(:device) { build(:device) }
  let(:params) { { imei: device.imei, mac: device.mac, serial_number: device.serial_number } }

  describe "POST create" do
    before do
      http_login(admin.email, admin.access_token)
    end

    it "creates the device if it doesn't exist" do
      expect { post :create, params: params }.to change(Device, :count).by(1)
    end

    it "updates the device asset_tracker even if device is already saved" do
      device.save!
      params["asset_id"] = "H01"
      expect(device.asset_tracker).to be_nil
      post :create, params: params
      expect(device.reload.asset_tracker).to eq("H01")
    end
  end
end
