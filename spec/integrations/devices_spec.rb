require 'rails_helper'

RSpec.describe "Devices view", type: :feature do
  let(:user) { create(:user, role: "glowball") }
  let!(:team) { create(:team, leader: user) }
  let!(:device) { create(:device, asset_tracker: "E15", team: team) }

  before(:each) do
    login_as(user, scope: :user)
    visit admins_user_team_devices_path(user)
  end

  describe "actions in device view" do
    it "select a device" do
      click_link("device_#{device.id}")
      expect(page).to have_current_path(admins_user_team_device_path(user, device.id))
    end

    it "edit a device" do
      click_link("edit_#{device.id}")
      expect(page).to have_current_path(edit_admins_user_team_device_path(user, device.id))
      fill_in 'device_asset_tracker', with: "A12"
      expect { find("input[name=commit]").click }.to change { device.reload.asset_tracker }.to("A12")
    end
    
    it "cannot edit a device with existent name" do
      existent_device = create(:device, asset_tracker: "A12", team: team)
      click_link("edit_#{device.id}")
      expect(page).to have_current_path(edit_admins_user_team_device_path(user, device.id))
      fill_in 'device_asset_tracker', with: existent_device.asset_tracker
      expect { find("input[name=commit]").click }.not_to change { device.reload.asset_tracker }
    end

    it "delete a device without transactions" do
      expect { click_link("delete_#{device.id}") }.to change(Device, :count).by(-1)
    end

    it "cannot delete a device with transactions" do
      create(:device_transaction, :with_device, event: create(:event), device: device)
      expect { click_link("delete_#{device.id}") }.not_to change(Device, :count)
      expect(page).to have_current_path(admins_user_team_device_path(user, device.id))
    end
  end
  
end
