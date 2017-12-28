require 'rails_helper'

RSpec.describe "Devices view", type: :feature do
  let(:user) { create(:user, role: "glowball") }
  let!(:device) { create(:device, asset_tracker: "E15") }

  before(:each) do
    login_as(user, scope: :user)
    visit admins_devices_path
  end

  describe "actions in device view" do
    it "select a device" do
      click_link("device_#{device.id}")
      expect(page).to have_current_path(admins_device_path(device.id))
    end

    it "edit a device" do
      click_link("edit_#{device.id}")
      expect(page).to have_current_path(edit_admins_device_path(device.id))
      within("#edit_device_#{device.id}") { fill_in 'device_asset_tracker', with: "A12" }
      expect { find("input[name=commit]").click }.to change { device.reload.asset_tracker }.to("A12")
    end

    it "delete a device without transactions" do
      expect { click_link("delete_#{device.id}") }.to change(Device, :count).by(-1)
    end

    it "cannot delete a device with transactions" do
      create(:device_transaction, :with_device, event: create(:event), device: device)
      expect { click_link("delete_#{device.id}") }.not_to change(Device, :count)
      expect(page).to have_current_path(admins_device_path(device.id))
    end
  end
end
