require 'rails_helper'

RSpec.describe "Users view", type: :feature, js: true do
  let!(:glowball) { create(:user, role: "glowball") }
  let!(:admin) { create(:user, role: "admin") }

  before { login_as(glowball, scope: :user) }

  describe "users view link" do
    before { visit admin_root_path }

    it "all users are displayed" do
      find("#user_dropdown").hover
      find("#users_layout_link").click
      within("#user_list") do
        expect(page).to have_current_path(admins_users_path)
        expect(page).to have_text glowball.username.to_s
        expect(page).to have_text admin.username.to_s
      end
    end
  end

  describe "actions in user view" do
    before { visit admins_users_path }

    it "select a user" do
      find("#user_#{admin.id}_email").click
      expect(page).to have_current_path(admins_user_path(admin.id))
    end

    it "add a user" do
      find("#floaty").hover
      find("#new_user_link").click
      expect(page).to have_current_path(new_admins_user_path)
    end

    pending "delete a user" do
      find("#floaty").hover
      expect { confirm_alert { find("#user_#{admin.id}_delete").click } }.to change(User, :count).by(-1)
    end
  end

  describe "search user" do
    before { visit admins_users_path }

    it "type username" do
      find("#search_icon").click
      within("#user_search") { fill_in 'fixed-header-drawer-exp', with: admin.username.to_s }.native.send_keys(:return)
      within("#user_list") do
        expect(page).not_to have_text glowball.username.to_s
        expect(page).to have_text admin.username.to_s
      end
    end

    it "type email" do
      find("#search_icon").click
      within("#user_search") { fill_in 'fixed-header-drawer-exp', with: admin.email.to_s }.native.send_keys(:return)
      within("#user_list") do
        expect(page).not_to have_text glowball.email.to_s
        expect(page).to have_text admin.email.to_s
      end
    end

    it "type non-existent user name" do
      find("#search_icon").click
      within("#user_search") { fill_in 'fixed-header-drawer-exp', with: "non-existent" }.native.send_keys(:return)
      within("#user_list") do
        expect(page).not_to have_text glowball.username.to_s
        expect(page).not_to have_text admin.username.to_s
      end
    end

    it "don't type user name" do
      find("#search_icon").click
      within("#user_search") { fill_in 'fixed-header-drawer-exp', with: "" }.native.send_keys(:return)
      within("#user_list") do
        expect(page).to have_text glowball.username.to_s
        expect(page).to have_text admin.username.to_s
      end
    end
  end
end
