require 'rails_helper'

RSpec.describe "Devices view", js:true, type: :feature do

  before(:each) do
    @user_glowball = create(:user, role:"glowball")
    @event = create(:event)
    @device_1 = create(:device, asset_tracker:"E15")
    @device_2 = create(:device, asset_tracker:"F26")
    create(:device_transaction, :with_device, event: @event, device: @device_2)
    login_as(@user_glowball, scope: :user)
    visit admins_devices_path
  end

  describe "actions in device view" do

    it "select a device" do
      find_by_id("#{@device_1.id}").click
      expect(page).to have_current_path(admins_device_path(@device_1.id))
    end

    it "edit a device" do
      find_by_id("#{@device_1.id}_edit").click
      expect(page).to have_current_path(edit_admins_device_path(@device_1.id))
      within("#edit_device_#{@device_1.id}"){fill_in 'device_asset_tracker', with:"A12"}
      find("input[name=commit]").click
      expect(page).to have_current_path(admins_device_path(@device_1.id))
      find("#undo_link").click
      within 'table' do
        expect(page).not_to have_text "#{@device_1.asset_tracker}"
        expect(page).to have_text "A12"
      end
    end

    it "delete a device without transactions" do
      expect do
        find_by_id("#{@device_1.id}_delete").click
        page.accept_alert
        sleep(1)
      end.to change(Device, :count).by(-1)
    end

    it "delete a device with transactions" do
      expect do
        find_by_id("#{@device_2.id}_delete").click
        page.accept_alert
        sleep(1)
      end.not_to change(Device, :count)
      expect(page).to have_current_path(admins_device_path(@device_2.id))
    end
  end

  describe "search device" do

    it "type asset number" do
      find("#search_icon").click
      within("#device_search") {fill_in 'fixed-header-drawer-exp', with: "#{@device_1.asset_tracker}"}.native.send_keys(:return)
      within 'table' do
        expect(page).not_to have_text "#{@device_2.asset_tracker}"
        expect(page).to have_text "#{@device_1.asset_tracker}"
      end
    end

    it "type mac" do
      find("#search_icon").click
      within("#device_search") {fill_in 'fixed-header-drawer-exp', with: "#{@device_1.mac}"}.native.send_keys(:return)
      within 'table' do
        expect(page).not_to have_text "#{@device_2.asset_tracker}"
        expect(page).to have_text "#{@device_1.asset_tracker}"
      end
    end

    it "type non-existent asset number" do
      find("#search_icon").click
      within("#device_search") {fill_in 'fixed-header-drawer-exp', with: "non-existent"}.native.send_keys(:return)
      within 'table' do
        expect(page).not_to have_text "#{@device_1.asset_tracker}"
        expect(page).not_to have_text "#{@device_2.asset_tracker}"
      end
    end

    it "don't type anything" do
      find("#search_icon").click
      within("#device_search") {fill_in 'fixed-header-drawer-exp', with: ""}.native.send_keys(:return)
      within 'table' do
        expect(page).to have_text "#{@device_1.asset_tracker}"
        expect(page).to have_text "#{@device_2.asset_tracker}"
      end
    end
  end

end
